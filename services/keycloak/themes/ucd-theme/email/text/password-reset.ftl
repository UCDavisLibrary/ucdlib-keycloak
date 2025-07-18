<#setting url_escaping_charset='UTF-8'>
<#assign clientId = properties.clientId!''>
<#assign realmName = properties.realmName!''>
<#assign realmDisplayName = properties.realmDisplayName!''>
<#assign redirectUri = url.keycloakUrl!''>
<#assign baseUrl = url.keycloakUrl!''>

<#assign flowLink = baseUrl + "/realms/" + realmName +
  "/protocol/openid-connect/auth" +
  "?client_id=" + clientId +
  "&response_type=code" +
  "&scope=openid" +
  "&redirect_uri=" + redirectUri?url +
  "&kc_action=UPDATE_PASSWORD">

You have requested to reset your password for ${realmDisplayName}.

Please open the following link to continue:

${flowLink}

This link will expire in ${linkExpirationFormatter(linkExpiration)}.