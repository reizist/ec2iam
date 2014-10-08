require 'ec2iam'
require 'thor'
require 'aws-sdk'
require 'ec2iam/iam_config'
include Ec2Iam

module Ec2Iam
  class CLI < Thor
    class_option 'all-profiles', type: :boolean, desc: 'Run with all profiles'
    class_option :profile, type: :string ,aliases: '-p', desc: 'Run with specify profile'

    desc "create user_name", "create iam user with name 'user_name' who belongs to ReadOnly group."
    option :save, type: :boolean, desc: "save credentials to file"
    def create(user_name)
      if options['all-profiles']
        keys_array = []
        IamConfig::CONFIG.each do |profile, credentials|
          set_client(profile)
          say("On #{profile}:")
          keys_array << { profile: profile, credentials: create_user(user_name) }
        end

        IamConfig.write_keys(user_name, keys_array) if options[:save]
      else
        options[:profile] ? set_client(options[:profile]) : set_client

        if options[:save]
          IamConfig.write_key(user_name, IamConfig.format_key(@client.profile, create_user(user_name)))
        else
          create_user(user_name)
        end
      end
    end

    desc "delete! user_name", "delete iam user with user_name perfectly."
    long_desc <<-LONGDESC
    "Deletes the current user, after:
      * deleting its login profile
      * removing it from all groups
      * deleting all of its access keys
      * deleting its mfa devices * deleting its signing certificates"
    LONGDESC
    def delete!(user_name)
      if options['all-profiles']
        IamConfig::CONFIG.each do |profile, credentials|
          set_client(profile)
          say("On #{profile}:")
          delete_user!(user_name)
        end
      else
        options[:profile] ? set_client(options[:profile]) : set_client
        delete_user!(user_name)
      end
    end

    desc "list", "list iam users on the account."
    def list
      if options['all-profiles']
        IamConfig::CONFIG.each do |profile, credentials|
          set_client(profile)
          say("On #{profile}:")
          list_user
        end
      else
        options[:profile] ? set_client(options[:profile]) : set_client
        list_user
      end
    end

    no_tasks do
      def set_client(profile='default')
        begin
          @client = IamConfig.new(profile)
        rescue AccountKeyNotFound
          say("account_key #{profile} was not found on iam.yml", :red)
          exit(1)
        end
      end

      def create_user(user_name)
        begin
          user = @client.iam.users.create(user_name)
          user.groups.add(@client.group)
          say("create #{user_name} done.", :green)
          access_key = user.access_keys.create
          credentials = access_key.credentials
          say("#{IamConfig.format_key(@client.profile, credentials)}", :green)
          credentials
        rescue AWS::IAM::Errors::EntityAlreadyExists
          say("User '#{user_name}' has already exists. Please retry with another name.", :red)
        end
      end

      def delete_user!(user_name)
        begin
          @client.iam.users[user_name].delete!
          say("delete #{user_name}.", :red)
        rescue AWS::IAM::Errors::NoSuchEntity
          say("User '#{user_name}' Not Found. Please retry with another name.", :red)
        end
      end

      def list_user
        @client.iam.users.each {|u| puts u.name}
      end
    end
  end
end
