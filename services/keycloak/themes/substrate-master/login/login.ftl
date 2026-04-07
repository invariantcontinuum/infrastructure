<#import "template.ftl" as layout>
<@layout.registrationLayout
    displayMessage=!messagesPerField.existsError('username','password')
    displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>

    <#macro socialProviderButton p>
        <#assign providerHint=(p.alias!'')?lower_case>
        <#if !providerHint?has_content>
            <#assign providerHint=(p.displayName!'')?lower_case>
        </#if>
        <a href="${p.loginUrl}" class="sub-social-btn" id="social-${p.alias}">
            <#if providerHint?contains("github")>
                <img src="${url.resourcesPath}/img/github-mark.svg" class="sub-social-icon" alt="" aria-hidden="true">
            <#elseif p.iconClasses?has_content>
                <i class="${p.iconClasses!}" aria-hidden="true"></i>
            </#if>
            <span>${p.displayName!p.alias}</span>
        </a>
    </#macro>

    <#if section = "form">

        <#if realm.internationalizationEnabled && locale.supported?size gt 1>
            <div class="sub-locale">
                <select onchange="window.location.href=this.value" class="sub-locale-select" aria-label="Language">
                    <#list locale.supported as l>
                        <option value="${l.url}" <#if l.selected>selected</#if>>${l.label}</option>
                    </#list>
                </select>
            </div>
        </#if>

        <div class="sub-form-intro">
            <h1 class="sub-form-title">Welcome Site Admin!</h1>
            <p class="sub-form-subtitle">Use your Substrate Master account to continue.</p>
        </div>

        <#if social?? && social.providers?has_content>
            <div class="sub-social">
                <#list social.providers as p>
                    <@socialProviderButton p=p/>
                </#list>
            </div>

            <#if realm.password>
                <div class="sub-or">
                    <span>or continue with email</span>
                </div>
            </#if>
        </#if>

        <#if realm.password>
            <form id="kc-form-login" action="${url.loginAction}" method="post">
                <div class="sub-field <#if messagesPerField.existsError('username')>sub-field-error</#if>">
                    <label for="username" class="sub-label">
                        <#if !realm.loginWithEmailAllowed>
                            ${msg("username")}
                        <#elseif !realm.registrationEmailAsUsername>
                            ${msg("usernameOrEmail")}
                        <#else>
                            ${msg("email")}
                        </#if>
                    </label>
                    <input
                        id="username"
                        name="username"
                        type="text"
                        class="sub-input"
                        value="${login.username!''}"
                        autocomplete="username"
                        autofocus
                        tabindex="1"
                        <#if usernameEditDisabled??>disabled</#if>
                        aria-invalid="<#if messagesPerField.existsError('username')>true</#if>"
                    >
                    <#if messagesPerField.existsError('username')>
                        <span class="sub-field-msg">${kcSanitize(messagesPerField.get('username'))?no_esc}</span>
                    </#if>
                </div>

                <div class="sub-field <#if messagesPerField.existsError('password')>sub-field-error</#if>">
                    <label for="password" class="sub-label">${msg("password")}</label>
                    <input
                        id="password"
                        name="password"
                        type="password"
                        class="sub-input sub-input-password"
                        autocomplete="current-password"
                        tabindex="2"
                        aria-invalid="<#if messagesPerField.existsError('password')>true</#if>"
                    >
                    <#if messagesPerField.existsError('password')>
                        <span class="sub-field-msg">${kcSanitize(messagesPerField.get('password'))?no_esc}</span>
                    </#if>
                </div>

                <div class="sub-form-extras">
                    <#if realm.rememberMe && !usernameEditDisabled??>
                        <label class="sub-checkbox-label">
                            <input
                                type="checkbox"
                                id="rememberMe"
                                name="rememberMe"
                                class="sub-checkbox"
                                tabindex="3"
                                <#if login.rememberMe??>checked</#if>
                            >
                            <span>${msg("rememberMe")}</span>
                        </label>
                    </#if>
                    <#if realm.resetPasswordAllowed>
                        <a href="${url.loginResetCredentialsUrl}" class="sub-link-muted" tabindex="5">
                            ${msg("doForgotPassword")}
                        </a>
                    </#if>
                </div>

                <input type="hidden" id="id-hidden-input" name="credentialId"
                    <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>>

                <button type="submit" id="kc-login" class="sub-btn" tabindex="4" name="login">
                    ${msg("doLogIn")}
                </button>
            </form>
        </#if>

    <#elseif section = "info">

        <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
            <p class="sub-register-text">
                ${msg("noAccount")}
                <a href="${url.registrationUrl}" class="sub-link" tabindex="6">${msg("doRegister")}</a>
            </p>
        </#if>

    </#if>

</@layout.registrationLayout>
