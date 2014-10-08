require 'yaml'
module Ec2Iam
  class AccountKeyNotFound < StandardError; end
  class IamConfig
    attr_reader :iam, :group, :profile

    GROUP_NAME = 'EC2ReadOnly'
    CONFIG = YAML.load_file(File.join(Dir.home, '.aws/iam.yml')).freeze

    def initialize(account_key)
      @profile = account_key
      raise AccountKeyNotFound if CONFIG[@profile] == nil

      @iam = AWS::IAM.new(
        access_key_id: CONFIG[@profile]['access_key_id'],
        secret_access_key: CONFIG[@profile]['secret_access_key']
      )

      @group = @iam.groups[GROUP_NAME].exists? ? @iam.groups[GROUP_NAME] : create_ec2_read_only_group
    end

    def self.format_key(profile, key)
<<-KEY
aws_keys(
  #{profile}: { access_key_id: #{key[:access_key_id]}, secret_access_key: #{key[:secret_access_key]} }
)
KEY
    end

    def create_ec2_read_only_group
      policy = AWS::IAM::Policy.new do |p|
        p.allow(
          actions: ["ec2:Describe*"],
          resources: "*"
        )
      end
      group = @iam.groups.create(GROUP_NAME)
      group.policies[GROUP_NAME] = policy
      group
    end

    def self.write_key(user_name, formatted_str)
      File.open("#{Dir.home}/.aws/#{user_name}.yml", "a") do |f|
        f.write(formatted_str)
      end
    end

    def self.write_keys(user_name, array)
      str = "aws_keys(\n"

      array.each do |hash|

str << <<-KEYS
  #{hash[:profile]}: { access_key_id: #{hash[:credentials][:access_key_id]}, secret_access_key: #{hash[:credentials][:secret_access_key]} },
KEYS
      end

      str << ")\n"

      write_key(user_name, str)
    end
  end
end
