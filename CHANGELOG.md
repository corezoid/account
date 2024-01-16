# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Chart 0.1.18 [SingleSpace 3.2.0] - 2023-12-06
### Helm changes
- New applications versions:
  - auth - 3.2.4
  - workspace - 3.2.4
  - ingress - 0.1.0
- Added to app names `account-`
- Added new application `account-frontend` - currently in development, should be disabled
- Refactor sub charts

### Improvements / New Features

On the Roles tab, the Roles table has been improved:
- Virtualisation has been added.
- The limit of pagination parameters has been increased to 999.


## Chart 0.1.17 [SingleSpace 3.1.1] - 2023-12-06
### Helm changes
- New applications versions:
   - auth - 3.1.1
   - workspace - 3.1.1
   - ingress - 0.1.0
- Rename application `singlespace` to `workspace`
- Add new application `auth` for authorization
- Refactor sub charts

### Improvements / New Features

#### 3.1.0:
- Created the public API of the following groups: Workspaces, Groups, Invites, Users. For more information, go to Swager.
- You can transfer your Workspace ownership to another user. When you leave a Workspace, transfer your Workspace ownership to another user, have been removed from a Workspace, or remove a user form a Workspace, you have to transfer your/removed user’s objects ownership to another user. For more information, go to Settings.
- Created MVP of the new authorization module.
- When you invite a user to your Workspace, your invitation has no expiration date, and the invited user can confirm your invitation after any period of time.

#### 3.0:
- On the Roles tab, you can see the roles as a list with the number of permissions and users for each role by clicking the corresponding icon in the upper-right corner of the page.
- Implemented a new module with licenses that allows you to buy a license, make payments, track state changes, and so on.
- Your company in Corezoid will appear as your company in Simulator as well. But when deleting the last company, you will have a new one anyway as you cannot have no company on the platform.


## Chart 0.0.17 [SingleSpace 2.14.2] - 2023-08-19
### Helm changes
- New applications versions:
    singlespace - 2.15.1
    ingress - 0.1.0

- Add `Role`, `RoleBinding` and `ServiceAccount` for singlespace appliction
- Add new block for `serviceAccount`

```
      # Specifies whether a service account should be created
      serviceAccount:
        create: false
        # You can provide your serviceAccount name to use, also set create to false
        # name: ""
        annotations: {}
        # annotations:
        # ## Enable if EKS IAM for SA is used
        #   eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/my-role
```

## Chart 0.0.16 [SingleSpace 2.14.0] - 2023-07-25
### Helm changes
- New applications versions:
    singlespace - 2.14.0


## Chart 0.0.15 [SingleSpace 2.13.0] - 2023-06-07
### Helm changes
- New applications versions:
    singlespace - 2.13.0


## Chart 0.0.14 [SingleSpace 2.11.0] - 2023-05-26
### Helm changes
- New applications versions:
    singlespace - 2.11.0


## Chart 0.0.13 [SingleSpace 2.10.0] - 2023-05-25
### Helm changes
- New applications versions:
    singlespace - 2.10.0


## Chart 0.0.12 [SingleSpace 2.9.0] - 2023-05-11
### Helm changes
- New applications versions:
    singlespace - 2.9.0
- Add new parameter `secret`. Must be same as `admin_bearer_token_secret` in `single_account.config` file


## Chart 0.0.11 [SingleSpace 2.6.1] - 2023-04-19
### Helm changes
- New applications versions:
    singlespace - 2.6.1


## Chart 0.0.10 [SingleSpace 2.6.1] - 2023-04-06
### Helm changes

- Аdded the ability to work with self-signed certificates

#### Improvements

- Draft implementation of webhooks.
- New config parameter: tls.insecure_skip_verify - skips certificate validation in http requests.

#### Feature

- Initiate changelog file


## Chart 0.0.9 [SingleSpace 2.5.0] - 2023-04-06
### Helm changes

- New chart release
- New application version
    singlespace - 2.5.0


## Chart 0.0.8 [SingleSpace 2.4.0] - 2023-03-29
### Helm changes

- New chart release
- New application version


## Chart 0.0.1 [SingleSpace 2.0.0] - 2023-01-13
### Helm changes

- Init chart
