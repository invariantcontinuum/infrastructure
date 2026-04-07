<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false>
<!DOCTYPE html>
<html lang="${(locale.currentLanguageTag)!"en"}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex, nofollow">
    <title>Substrate</title>
    <link rel="icon" type="image/svg+xml" href="${url.resourcesPath}/img/favicon.svg">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,300;0,9..144,600;1,9..144,300;1,9..144,400;1,9..144,600&family=Instrument+Sans:wght@400;500;600&display=swap" rel="stylesheet">

    <#if properties.styles?has_content>
        <#list properties.styles?split(' ') as style>
            <link href="${url.resourcesPath}/${style}" rel="stylesheet">
        </#list>
    </#if>
</head>
<body>
<div class="sub-page">
    <header class="sub-header">
        <div class="sub-brand">
            <span class="sub-brand-mark" aria-hidden="true"></span>
            <div class="sub-brand-copy">
                <span class="sub-brand-name">Substrate</span>
                <p class="sub-brand-tag">Secure access portal</p>
            </div>
        </div>
    </header>

    <main class="sub-card<#if bodyClass?has_content> ${bodyClass}</#if>" role="main">
        <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
            <div class="sub-alert sub-alert-${message.type}" role="alert">
                <span>${kcSanitize(message.summary)?no_esc}</span>
            </div>
        </#if>

        <#nested "form">

        <#if displayInfo>
            <div class="sub-divider"></div>
            <div class="sub-info">
                <#nested "info">
            </div>
        </#if>
    </main>
</div>

<#if scripts??>
    <#list scripts as script>
        <script src="${script}" type="text/javascript"></script>
    </#list>
</#if>
</body>
</html>
</#macro>
