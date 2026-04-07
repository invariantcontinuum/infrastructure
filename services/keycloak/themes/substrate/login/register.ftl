<#import "template.ftl" as layout>
<@layout.registrationLayout
    bodyClass="sub-card--register"
    displayMessage=!messagesPerField.existsError('firstName','lastName','email','username','password','password-confirm')
    displayInfo=false; section>

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
            <h1 class="sub-form-title">Create account</h1>
            <p class="sub-form-subtitle">Set up a new Substrate account.</p>
        </div>

        <form id="kc-register-form" action="${url.registrationAction}" method="post">
            <div class="sub-field-row">
                <div class="sub-field <#if messagesPerField.existsError('firstName')>sub-field-error</#if>">
                    <label for="firstName" class="sub-label">${msg("firstName")}</label>
                    <input
                        id="firstName"
                        name="firstName"
                        type="text"
                        class="sub-input"
                        value="${(register.formData.firstName)!''}"
                        autocomplete="given-name"
                        autofocus
                        tabindex="1"
                        aria-invalid="<#if messagesPerField.existsError('firstName')>true</#if>"
                    >
                    <#if messagesPerField.existsError('firstName')>
                        <span class="sub-field-msg">${kcSanitize(messagesPerField.get('firstName'))?no_esc}</span>
                    </#if>
                </div>

                <div class="sub-field <#if messagesPerField.existsError('lastName')>sub-field-error</#if>">
                    <label for="lastName" class="sub-label">${msg("lastName")}</label>
                    <input
                        id="lastName"
                        name="lastName"
                        type="text"
                        class="sub-input"
                        value="${(register.formData.lastName)!''}"
                        autocomplete="family-name"
                        tabindex="2"
                        aria-invalid="<#if messagesPerField.existsError('lastName')>true</#if>"
                    >
                    <#if messagesPerField.existsError('lastName')>
                        <span class="sub-field-msg">${kcSanitize(messagesPerField.get('lastName'))?no_esc}</span>
                    </#if>
                </div>
            </div>

            <div class="sub-field <#if messagesPerField.existsError('email')>sub-field-error</#if>">
                <label for="email" class="sub-label">${msg("email")}</label>
                <input
                    id="email"
                    name="email"
                    type="email"
                    class="sub-input"
                    value="${(register.formData.email)!''}"
                    autocomplete="email"
                    tabindex="3"
                    aria-invalid="<#if messagesPerField.existsError('email')>true</#if>"
                >
                <#if messagesPerField.existsError('email')>
                    <span class="sub-field-msg">${kcSanitize(messagesPerField.get('email'))?no_esc}</span>
                </#if>
            </div>

            <#if !realm.registrationEmailAsUsername>
                <div class="sub-field <#if messagesPerField.existsError('username')>sub-field-error</#if>">
                    <label for="username" class="sub-label">${msg("username")}</label>
                    <input
                        id="username"
                        name="username"
                        type="text"
                        class="sub-input"
                        value="${(register.formData.username)!''}"
                        autocomplete="username"
                        tabindex="4"
                        aria-invalid="<#if messagesPerField.existsError('username')>true</#if>"
                    >
                    <#if messagesPerField.existsError('username')>
                        <span class="sub-field-msg">${kcSanitize(messagesPerField.get('username'))?no_esc}</span>
                    </#if>
                </div>
            </#if>

            <#if passwordRequired??>
                <div class="sub-field <#if messagesPerField.existsError('password')>sub-field-error</#if>">
                    <label for="password" class="sub-label">${msg("password")}</label>
                    <input
                        id="password"
                        name="password"
                        type="password"
                        class="sub-input sub-input-password"
                        autocomplete="new-password"
                        tabindex="5"
                        aria-invalid="<#if messagesPerField.existsError('password')>true</#if>"
                    >
                    <#if messagesPerField.existsError('password')>
                        <span class="sub-field-msg">${kcSanitize(messagesPerField.get('password'))?no_esc}</span>
                    </#if>
                </div>

                <div class="sub-field <#if messagesPerField.existsError('password-confirm')>sub-field-error</#if>">
                    <label for="password-confirm" class="sub-label">${msg("passwordConfirm")}</label>
                    <input
                        id="password-confirm"
                        name="password-confirm"
                        type="password"
                        class="sub-input sub-input-password"
                        autocomplete="new-password"
                        tabindex="6"
                        aria-invalid="<#if messagesPerField.existsError('password-confirm')>true</#if>"
                    >
                    <#if messagesPerField.existsError('password-confirm')>
                        <span class="sub-field-msg">${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}</span>
                    </#if>
                </div>
            </#if>

            <#if recaptchaRequired??>
                <div class="sub-field">
                    <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
                </div>
            </#if>

            <button type="submit" id="kc-register" class="sub-btn" tabindex="7">
                ${msg("doRegister")}
            </button>
        </form>

        <div class="sub-divider"></div>

        <div class="sub-info">
            <p class="sub-register-text">
                Already have an account?
                <a href="${url.loginUrl}" class="sub-link" tabindex="8">${msg("doLogIn")}</a>
            </p>
        </div>

    </#if>

</@layout.registrationLayout>
