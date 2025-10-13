
<#include "header.ftl">

<div class="login-box">
  <div class="login-heading">
    <div class="icon-container">
      <svg class="library-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 276.31 432.01"><path d="M102.37,337.79,148,325.38c13.66-3.71,24-17.44,24-31.94V121.15l-69.56-11Z" style="fill:#ffbf00"></path><path d="M171.94,87.9V0L24.87,31.15C10.69,34.15,0,47.81,0,63v302.7l69.55-18.93v-275Z" style="fill:#ffbf00"></path><path d="M250.56,100.25,171.94,87.9v33.26l71.49,11.24V393.6l-141-22.18V337.8l-32.84,8.94v25.48c0,15.3,11.3,29.06,25.72,31.33l181,28.46V131.58C276.27,116.28,265,102.52,250.56,100.25Z" style="fill:#022851"></path></svg>
    </div>  
    
    <h2>Sign into ${realm.displayName}</h2>
  </div>

  <#if social?? && social.providers?has_content>
    <#list social.providers as idp>
      <#if idp.alias == "cas-oidc">
        <div class="cas-login">
          <h4>UC Davis Faculty, Staff and Students</h4>
          <a class="btn btn--primary btn--block" href="${idp.loginUrl}">Sign In (UC Davis CAS)</a>
        </div>
      </#if>
    </#list>
  </#if>
  
  <div class="divider">
    <hr/>
    <p>OR</p>
    <hr/>
  </div>

  <h4 class="external">External Affiliates</h4>
  <#if message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
    <div class="alert alert-${message.type}">
      <#if message.type = 'success'><span class="pficon pficon-ok"></span></#if>
      <#if message.type = 'warning'><span class="pficon pficon-warning-triangle-o"></span></#if>
      <#if message.type = 'error'><span class="pficon pficon-error-circle-o"></span></#if>
      <#if message.type = 'info'><span class="pficon pficon-info"></span></#if>
      <span class="kc-feedback-text">${kcSanitize(message.summary)?no_esc}</span>
    </div>
  </#if>
  <form action="${url.loginAction}" method="post">
      <div class="field-container form-group">
        <i class="fas fa-user"></i>
        <input id="username" name="username" type="text" placeholder="Username or Email">
      </div>
      <div class="field-container form-group">
        <i class="fas fa-lock"></i>
        <input id="password" name="password" type="password" name="password" placeholder="Password"/>
      </div>
      <div class="actions">
        <input class="btn btn--primary btn--block" type="submit" value="Sign In" />
        <#if realm.resetPasswordAllowed>
          <a href="${url.loginResetCredentialsUrl}" class="forgot-password">Forgot Password?</a>
        </#if>
      </div>
  </form>    
</div>

<#include "footer.ftl">
