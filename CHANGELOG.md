# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Chart 0.2.16 [SingleSpace 3.15.0] - 2024-11-29.
### Helm changes
- Applications versions:
  - auth - 3.15.0
  - workspace - 3.15.0
  - frontend - 3.15.0
  - ingress - 0.1.2
- Bug fixes for the groups APIs
- SSO authorization added

## Chart 0.2.15 [SingleSpace 3.14.0] - 2024-11-15.
### Helm changes
- Applications versions:
  - auth - 3.14.0
  - workspace - 3.14.0
  - frontend - 3.14.0
  - ingress - 0.1.2


## Chart 0.2.14 [SingleSpace 3.13.0] - 2024-10-18.
### Helm changes
- Applications versions:
  - auth - 3.13.2
  - workspace - 3.13.2
  - frontend - 3.13.0
  - ingress - 0.1.2
- Bugfix
- Metrics are enabled by default

## Chart 0.2.13 [SingleSpace 3.13.0] - 2024-10-10.
### Helm changes
- Applications versions:
  - auth - 3.13.1
  - workspace - 3.13.1
  - frontend - 3.13.0
  - ingress - 0.1.2
- Add `liveness` and `readiness` for `auth` and `workspace` applications


## Chart 0.2.12 [SingleSpace 3.13.0] - 2024-10-08.
### Helm changes
- Applications versions:
  - auth - 3.13.1
  - workspace - 3.13.1
  - frontend - 3.13.0
  - ingress - 0.1.2
- Added `cookie_same_site` attribute to the config (optional)
- New `imageRegistry` url

### Improvements / New Features
#### 1. client APIs added: CRUD operations for groups and API keys
#### 2. graceful shutdown added
#### 3. bug fixes


## Chart 0.2.11 [SingleSpace 3.12.5] - 2024-09-30.
### Helm changes
- Applications versions:
  - auth - 3.12.5
  - workspace - 3.12.5
  - frontend - 3.12.4
  - ingress - 0.1.2
- Add parameter `content_security_policy` in values file.
- The minimum number of characters in the password has been increased


## Chart 0.2.10 [SingleSpace 3.10.0] - 2024-07-31.
### Helm changes
- Applications versions:
    - auth - 3.10.6
    - workspace - 3.10.6
    - frontend - 3.10.0
    - ingress - 0.1.2
- Add parameter `portMetrics` in values file, using for define port for metrics
- Add monitoring for `auth`
- Update monitoring manifest for `workspace`

## Chart 0.2.9 [SingleSpace 3.10.0] - 2024-07-29.
### Helm changes
- New applications versions:
    - auth - 3.10.6
    - workspace - 3.10.6
    - frontend - 3.10.0
    - ingress - 0.1.2
- Remove hardcode registry domain from sub-charts. Switch to `{{ .Values.global.imageRegistry }}`

## Chart 0.2.8 [SingleSpace 3.10.0] - 2024-07-08
### Helm changes
- New applications versions:
    - auth - 3.10.0
    - workspace - 3.10.0
    - frontend - 3.10.0
    - ingress - 0.1.2

### Improvements / New Features

#### 1. The Webhooks page has been added to Settings where ** you can create, edit, manage, and delete webhooks.

    Note: You can manage webhooks if you have the Owner, Admin, Member or custom role and the Manage all webhooks permission.

#### 2. When you are transferring your workspace ownership to other user:
- You can cancel the ownership transfer before the selected user accepts it.
- The selected user can accept or decline the ownership transfer.
- The ownership transfer is canceled if the selected user is blocked or deleted.


## Chart 0.2.7 [SingleSpace 3.9.0] - 2024-06-26
### Helm changes
- Applications versions:
    - auth - 3.9.0
    - workspace - 3.9.0
    - frontend - 3.9.0
    - ingress - 0.1.2
- Changes for imagePullSecrets creation
```
      {{- if .Values.global.imagePullSecrets }}
      imagePullSecrets:
      {{- range $pullSecret := .Values.global.imagePullSecrets }}
        - name: {{ $pullSecret }}
      {{- end }}
      {{- end }}
```
- Remove hardcode `resources` from `values.yaml` file

## Chart 0.2.5 [SingleSpace 3.9.0] - 2024-06-12
### Helm changes
- New applications versions:
    - auth - 3.9.0
    - workspace - 3.9.0
    - frontend - 3.9.0
    - ingress - 0.1.2

### Improvements / New Features

#### 1. In the workspace dropdown list, you can see the list of workspaces you have access to and your roles in each workspace.

Note:

        If you have multiple roles in one workspace, they appear in a row below the workspace name.
        If the workspace is blocked, it has a red dot next to its name.

#### 2. On the Details tab of your paid online Cloud license, you can add another card details by clicking Change next to Payment method.

#### 3. The users with the Super admin role, can view:
- All the licenses and their details of all the users of the environment, filter them by Statuses (Active, Blocked, Cancelled, and Pending) and Ownership (Only my licenses), and edit license attribute details (for example, change RPS or cancel the license) of the other user paid license.
- All the payments and their details of all the users of the environment and filter them by Statuses (Paid, Failed, Pending).

#### 4. The users blocked due to the end of the license trial period can unblock themselves by passing the authorization process and logging in to the application again: Now, the free license don't have the expiration date.


## Chart 0.2.4 [SingleSpace 3.8.0] - 2024-05-28
### Helm changes
- New applications versions:
    - auth - 3.8.0
    - workspace - 3.8.0
    - frontend - 3.8.0
    - ingress - 0.1.2
- Refactor resources in helm chart, resources moved to values.yaml file.
- Updated code-style

### Improvements / New Features

#### 1. In the Licenses & Billing space, the super admin can:
 - View the Workspace page and all the workspaces with their details: workspace name, owner name, license type and ID, license owner name, number of workspace users, workspace status, and creation date. 
 - Upload the In-House license on their instance on the Upload license page of the Null Workspace.

       Note: When uploading a license, you can compare the previous license details and the actual one's in the dialog that appears.

#### 2. The workspace owner can configure the rules to invite users to their workspace:
 - To invite or not to invite users in general 
 - To allow all user domains 
 - To specify allowed user domains 
 - To specify prohibited user domains


## Chart 0.2.3 [SingleSpace 3.7.0] - 2024-05-07
### Helm changes
- New applications versions:
    - auth - 3.7.0
    - workspace - 3.7.0
    - frontend - 3.7.0
    - ingress - 0.1.2

### Improvements / New Features
- User migrations 
- Bug fix sql migration
- When you turn on the Enable Two-factor authentication toggle on the Profile page, the QR codes to upload the authentication application for Android and iOS appear on the step 2.
- When you buy a license on the Simulator.Company website, you can buy extra state changes by clicking Buy more on the Details tab of the license page.

## Chart 0.2.2 [SingleSpace 3.6.0] - 2024-04-25
### Helm changes
- New applications versions:
    - auth - 3.6.0
    - workspace - 3.6.0
    - frontend - 3.6.0
    - ingress - 0.1.2

### Improvements / New Features

#### 1. On the Licenses & Billing page:
- On the Licenses tab, you can view the type of license: Cloud, Desktop, or In-House.
- On the Payments tab, you can download the invoice of the license paid according to the agreement with the invoice.
- On the Details tab of a license, you can view state changes statistics: income amount, regular renewal amount, bonuses, used amount, and current balance.

#### 2. On the Roles page, you can edit the Member role permissions by selecting or clearing the needed checkboxes.


## Chart 0.2.1 [SingleSpace 3.5.0] - 2024-04-09
### Helm changes
- New applications versions:
    - auth - 3.5.0
    - workspace - 3.5.0
    - frontend - 3.5.1
    - ingress - 0.1.2
- Refactor sub charts

### Improvements / New Features

The following features have been added and improved:

#### 1. The password history has been added: you have to change your password after a specified period of time, and you cannot reuse any of your last 10 passwords.
        Note: This refers to those users who have registered by entering a username and password and not entered by using Google account. 

#### 2. You can select a colour instead of adding an image:

          a. On the Profile page for your avatar

          b. On the Keys page, when creating an API key 

#### 3. On the Users tab of the Groups page, you can see the Roles and Last login columns.


## Chart 0.2.0 [SingleSpace 3.4.0] - 2024-03-20
### Helm changes
- New applications versions:
    - auth - 3.4.0
    - workspace - 3.4.0
    - frontend - 3.4.0
    - ingress - 0.1.0
- Refactor sub charts
- Refactor values.yaml (we have added a separate config block for the auth and workspace applications)
- **Attention, Release of the new authorization module!
  This module operates independently of the Erlang application. Prior to installation, we recommend consulting for guidance.**

### Improvements / New Features

The following features have been added and improved:

#### 1. You can enter user names in Cyrillic in the Sign in form.
#### 2. The redesign of the Profile page has been implemented.
#### 3. You can view all your Workspaces even if you have them more than 100 by using scroll.
#### 4. The counters have been fixed when filtering users.


## Chart 0.1.18 [SingleSpace 3.2.0] - 2024-01-09
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
