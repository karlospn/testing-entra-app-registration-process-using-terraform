# **Testing Microsoft Entra App Registration process using Terraform**

This repository presents a common scenario designed for testing the app registration process in Microsoft Entra (aka. Azure Active Directory) using Terraform.

# **Scenario Details**

The following scenario is outlined:

- **Payments API**
  - Exposes 2 scopes:
    - _payment.write_ scope.
    - _payment.read_ scope.
  - It has 2 app roles:
    - A _Reader_ role.
    - An _Admin_ role.

- **Bookings API**
  - Consumes the Payments API through a **Client Credentials** flow.
    - Acquires an access_token from the Entra `/token` endpoint and utilizes it to gain access to the Payments API.
  - Has the Payments API _Reader_ Role assigned.

- **FrontEnd SPA**
  - A Single Page Application.
    - Utilizes an **Authorization Code flow with PKCE** to obtain an access token and uses it to access the Payments API.
  - The FrontEnd SPA app is granted permission only to request the `payment.write` scope.

- **User Permissions**
  - Two users are registered in my Entra:
    - John.
    - Jane.
  - Jane holds a `Reader` role in the Payments API app.
  - John possesses an `Admin` role in the Payments API app.

# **Scenario Authorization Diagrams**

The following diagrams shows the authorization flows we're building within this repository.

## **Bookings API Client Credentials Flow**

![client-creds-flow](https://raw.githubusercontent.com/karlospn/testing-entra-app-registration-process-using-terraform/main/docs/testing-entra-with-terraform-client-credentials.png)

## **FrontEnd SPA Authorization Code flow with PKCE**

![auth-code-flow-with-pkce](https://raw.githubusercontent.com/karlospn/testing-entra-app-registration-process-using-terraform/main/docs/testing-entra-with-terraform-auth-code-flow.png)

# **How to run this scenario**

There are multiple ways to setup the ``azuread`` Terraform provider. It supports a number of different methods for authenticating to Entra:

- Using the Azure CLI.
- Using a Managed Identity.
- Using a Service Principal and a Client Certificate.
- Using a Service Principal and a Client Secret.

This scenario uses the **Service Principal and a Client Secret** method. To achieve this, you must manually register an app in Entra with the following permissions for `Microsoft.Graph`:
- ``Application.ReadWrite.All``
- ``AppRoleAssignment.ReadWrite.All``
- ``User.Read.All``

![master-app-graph-permissions](https://raw.githubusercontent.com/karlospn/testing-entra-app-registration-process-using-terraform/main/docs/testing-entra-with-terraform-master-app-permissions.png)

Additionally, you need to create a new client secret for this app.

![master-app-client-secret](https://raw.githubusercontent.com/karlospn/testing-entra-app-registration-process-using-terraform/main/docs/testing-entra-with-terraform-master-app-secret.png)

Once these steps are completed, go to the `/src/environments/dev.tfvars` file and modify the following values accordingly:

- `master_application_client_id`: The Application ID of the created app.
- `master_application_client_secret`: The secret you generated.
- `tenant_id`: Your Entra Tenant ID.

After replacing the values in the `dev.tfvars` file, execute the following command: ``terraform apply --var-file=environments/dev.tfvars`` command, and we're done.

- Keep in mind, that Entra apps are authorized to call APIs when they are granted permissions by user/admins as part of the consent process. Therefore, it is necessary to manually grant admin consent for both the Bookings API and the FrontEnd SPA to call the Payments API.

![admin-grant-consent](https://raw.githubusercontent.com/karlospn/testing-entra-app-registration-process-using-terraform/main/docs/testing-entra-with-terraform-admin-grant-consent.png)

# **How to test this scenario**

## **Testing the Bookings API Client Credentials flow**

1- Request an access token using the Bookings API client id and client secret.

```text
curl -k -X POST \
  https://login.microsoftonline.com/8a0671e2-3a30-4d30-9cb9-ad709b9c744a/oauth2/v2.0/token \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'grant_type=client_credentials&client_id=e896bbda-6a3b-4309-a140-41c816049f09&client_secret=uPd8Q~D.Ntc1D2MbzTuJJwdIwxuFKVARezmURduC&scope=api://payments/.default'
```

2- Examine the received access token from Entra and verify that the token includes the following attributes:
  - The issuer should match your Entra ID tenant, formatted as: `https://login.microsoftonline.com/{tenant-id}/v2.0"`
  - The audience should match the client ID of the Payments API.
  - It must possess a "Reader" role.

```javascript
{
  "aud": "2034f5fd-8e85-48f0-8282-983ee03319b5",
  "iss": "https://login.microsoftonline.com/8a0671e2-3a30-4d30-9cb9-ad709b9c744a/v2.0",
  "iat": 1699874572,
  "nbf": 1699874572,
  "exp": 1699878472,
  "aio": "E2VgYLjBYnn7vPbZdxopTy/kGH5xqHmfEixWUtEp6W7OHiVbmQoA",
  "azp": "e896bbda-6a3b-4309-a140-41c816049f09",
  "azpacr": "1",
  "oid": "013f9e69-d867-42bd-9ea1-6b3dda3dd2df",
  "rh": "0.AR8A4nEGijA6ME2cua1wm5x0Sv31NCCFjvBIgoKYPuAzGbUfAAA.",
  "roles": [
    "Reader"
  ],
  "sub": "013f9e69-d867-42bd-9ea1-6b3dda3dd2df",
  "tid": "8a0671e2-3a30-4d30-9cb9-ad709b9c744a",
  "uti": "ZQMAaXC8q028-QpMeA5UAA",
  "ver": "2.0"
}
```

## **Testing the FrontEnd SPA Authorization Code flow with PKCE**

To easily test an Authorization Code flow with PKCE we're going to use this website:

- https://oidcdebugger.com/

Simply fill out the form with the appropriate fields and select code flow with PKCE. 

![oidc-debugger](https://raw.githubusercontent.com/karlospn/testing-entra-app-registration-process-using-terraform/main/docs/testing-entra-with-terraform-oidcdebugger.png)

Once you click submit, it will redirect you to Entra, where you'll need to log in.  In our case, for example, if we log in as Jane, we will obtain the following access token.

```javascript
{
  "aud": "2034f5fd-8e85-48f0-8282-983ee03319b5",
  "iss": "https://login.microsoftonline.com/8a0671e2-3a30-4d30-9cb9-ad709b9c744a/v2.0",
  "iat": 1699875872,
  "nbf": 1699875872,
  "exp": 1699879801,
  "aio": "AUQAu/8VAAAA08xo4ln4uUih+NlH44K4IF0O+d5Pib67ko9q+HksOcSeDlTVjhxBEl5e5fwSH7S70sMlpXXidbR4cDfYAGLxbQ==",
  "azp": "3e3d6cd6-e7b4-4394-81bc-17e4fa0c72d6",
  "azpacr": "0",
  "name": "jane",
  "oid": "0a92ffc5-9551-47a0-baf0-7f3352eac015",
  "preferred_username": "jane@carlosponsnoutlook.onmicrosoft.com",
  "rh": "0.AR8A4nEGijA6ME2cua1wm5x0Sv31NCCFjvBIgoKYPuAzGbUfAAc.",
  "roles": [
    "Reader"
  ],
  "scp": "payment.write",
  "sub": "ivrR0VeZR97QmF8h26WrjyOsPjcUdrhhTHyvYbeJt4Q",
  "tid": "8a0671e2-3a30-4d30-9cb9-ad709b9c744a",
  "uti": "E7EB8CFhCkGuRA4WzrItAA",
  "ver": "2.0"
}
```
And if you inspect the received access token from Entra, you can verify that the token includes the following attributes:

- The issuer should match your Entra ID tenant, formatted as: https://login.microsoftonline.com/{tenant-id}/v2.0"
- The audience should match the client ID of the Payments API.
- It must have a "Reader" role, as Jane is assigned the "Reader" role in the Payments API. If you log in as John, you will possess an "Admin" role instead of a "Reader" role.
