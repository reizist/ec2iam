## Introduce

ec2iam is a iam user manager for Amazon EC2.
Especially, very friendly for [ec2ssh](https://github.com/mirakui/ec2ssh)

## How to use
### 1. Prepare Administrator Account on AWS.
This gem use administrator account's access_key_id and secret_access_key for manage iam function on aws.

### 2. Edit ``` ~/.aws/iam ```
For accessing aws, please make ``` ~/.aws/iam ``` and set access key info like below.

``` ruby
default: { access_key_id: 'WURLWEKRJWEIRLSKDJF', secret_access_key: '8fjjwlergJU/fhafHgsdfaoLfl/HsdleiO' }
```

By default, each command try to access by using ``` default ``` key,
but if you want to switch aws account, you can set others access key like below.
 
``` ruby
default: { access_key_id: 'WURLWEKRJWEIRLSKDJF', secret_access_key: '8fjjwlergJU/fhafHgsdfaoLfl/HsdleiO' }
another_profile: { access_key_id: 'HOEUWLFJSDLFSUIARF', secret_access_key: '7f78LFDLGh/FJDojhg23dklsdHSDldkdi7' }
```


### 3. Bundle

## Commands

``` sh
Commands:
  ec2iam create user_name   # create iam user with name 'user_name' who belongs to ReadOnly group.
  ec2iam delete! user_name  # delete iam user with user_name perfectly.
  ec2iam help [COMMAND]     # Describe available commands or one specific command
  ec2iam list               # list iam users on the account.

Options:
      [--all-profiles], [--no-all-profiles]  # Run with all profiles
  -p, [--profile=PROFILE]                    # Run with specify profile
```

### options

##### --profile (aliases is '-p')
Each command can use ``` --profile ``` option to choose aws account on config file ``` iam ```

``` shell
$ ec2iam list --profile=another_profile
```

or

``` shell
$ ec2iam list -p another_profile
```

##### --all-profiles
When you handle multiple accounts(profiles), you are able to exec on all profiles like below.

``` shell
$ ec2iam create hoge --all-profiles

On default:
create hoge done.
aws_keys(
  default: { access_key_id: 'AKIAJCDTOJHTU26GVFTQ', secret_access_key: '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' }
)
On another_profile:
create hoge done.
aws_keys(
  another_profile: { access_key_id: 'AKIATWUADITSTEPVLR7A', secret_access_key: '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' }
)

```

#### On create command
##### --save
If you add `--save` option, created values are written in ``` ~/.aws/<username>.keys ```.

## ec2ssh
* Create IAM credentials.
``` ec2iam create hoge --save ```

* Copy each credentials on ``` ~/.aws/hoge.keys ``` to ``` ~/.ec2ssh ```

* Run ``` ec2ssh update ```

## Contributing

1. Fork it ( https://github.com/reizist/ec2iam/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
