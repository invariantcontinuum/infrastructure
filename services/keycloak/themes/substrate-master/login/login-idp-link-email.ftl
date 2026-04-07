<#import "template.ftl" as layout>
<@layout.registrationLayout
    bodyClass="sub-card--idp-link"
    displayMessage=messagesPerField.exists('global'); section>

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
            <h1 class="sub-form-title">${msg("emailLinkIdpTitle", idpDisplayName)}</h1>
            <p class="sub-form-subtitle">Link your existing admin account to continue.</p>
        </div>

        <div class="sub-copy-stack">
            <p class="sub-copy">
                ${msg("emailLinkIdp1", idpDisplayName, brokerContext.username, realm.displayName)}
            </p>
            <p class="sub-copy">
                ${msg("emailLinkIdp2")}
                <a href="${url.loginAction}" class="sub-link">${msg("doClickHere")}</a>
                ${msg("emailLinkIdp3")}
            </p>
            <p class="sub-copy">
                ${msg("emailLinkIdp4")}
                <a href="${url.loginAction}" class="sub-link">${msg("doClickHere")}</a>
                ${msg("emailLinkIdp5")}
            </p>
        </div>
    </#if>

</@layout.registrationLayout>
