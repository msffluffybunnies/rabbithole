<!--
  sysmon-config | A Sysmon configuration focused on default high-quality event tracing and easy customization by the community
  Master version:	64 | Date: 2018-01-30
  Master author:	@SwiftOnSecurity, other contributors also credited in-line or on Git
  Master project:	https://github.com/SwiftOnSecurity/sysmon-config
  Master license:	Creative Commons Attribution 4.0 | You may privatize, fork, edit, teach, publish, or deploy for commercial use - with attribution in the text.
  Fork version:	<N/A>
  Fork author:	<N/A>
  Fork project:	<N/A>
  Fork license:	<N/A>
  REQUIRED: Sysmon version 7.01 or higher (due to changes in registry syntax and bug-fixes)
	https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon
	Note that 6.03 and 7.01 have critical fixes for filtering, it's recommended you stay updated.
  NOTE: To collect Sysmon logs centrally for free, see https://aka.ms/WEF. Command to allow log access to the Network Service:
	wevtutil.exe sl Microsoft-Windows-Sysmon/Operational /ca:O:BAG:SYD:(A;;0xf0005;;;SY)(A;;0x5;;;BA)(A;;0x1;;;S-1-5-32-573)(A;;0x1;;;NS)
  NOTE: Do not let the size and complexity of this configuration discourage you from customizing it or building your own.
	This configuration is based around known, high-signal event tracing, and thus appears complicated, but it's only very
	detailed. Significant effort over years has been invested in front-loading as much filtering as possible onto the
	client. This is to make analysis of intrusions possible by hand, and to try to surface anomalous activity as quickly
	as possible to any technician armed only with Event Viewer. Its purpose is to democratize system monitoring for all organizations.
  NOTE: Sysmon is NOT a whitelist solution or HIDS engine, it is a computer change and event logging tool with very basic exclude rules.
	Do NOT ignore everything possible. Sysmon's purpose is providing context during a threat or problem investigation. Legitimate
	processes are routinely used by threats - do not blindly exclude them. Additionally, be mindful of process-hollowing / imitation.
  NOTE: Sysmon is not hardened against an attacker with admin rights. Additionally, this configuration offers an attacker, willing
	to study it, many ways to evade some of the logging. If you are in a high-threat environment, you should consider a much broader
	log-most approach. However, in the vast majority of cases, an attacker will bumble along through multiple behavioral traps which
	this configuration monitors, especially in the first minutes.
  TECHNICAL:
  - Run sysmon.exe -? for a briefing on Sysmon configuration.
  - Other languages may require localization. Registry and Filesystem paths can change. For example, \shell\open\command\, where "open" is localized.
  - Sysmon does not support nested/multi-conditional rules. There are only blanket INCLUDE and EXCLUDE. "Exclude" rules override "Include" rules.
  - If you only specify exclude for a filtering subsection, everything in that subsection is logged by default.
  - Some Sysmon monitoring abilities are not meant for widely deployed general-purpose use due to performance impact. Depends on environment.
  - Duplicate or overlapping "Include" rules do not result in duplicate events being logged.
  - All characters enclosed by XML tags are always interpreted literally. Sysmon does not support wildcards (*), alternate characters, or RegEx.
  - In registry events, the value name is appended to the full key path with a "\" delimiter. Default key values are named "\(Default)"
  - "Image" is a technical term for a compiled binary file like an EXE or DLL. Also, it can match just the filename, or entire path.
  - "ProcessGuid" is randomly generated, assigned, and tracked by Sysmon to assist in tracing individual process launches. Cleared on service restart.
  - "LoginGuid" is randomly generated, assigned, and tracked by Sysmon to assist in tracing individual user sessions. Cleared on service restart.
  - Sysmon does not track which rule caused an event to be logged.
  FILTERING: Filter conditions available for use are: is, is not, contains, excludes, begin with, end with, less than, more than, image
  - The "image" filter is usable with any field. Same as "is" but can either match the entire string, or only the text after the last "\" in the string. Credit: @mattifestation
  PERFORMANCE: By using "end with" you can save performance by starting a string match at the end of a line, which usually triggers earlier.
-->

<Sysmon schemaversion="4.00">
	<!--SYSMON META CONFIG-->
	<HashAlgorithms>md5,sha256</HashAlgorithms> <!-- Both MD5 and SHA256 are the industry-standard algorithms for identifying files -->
	<CheckRevocation/> <!-- Check loaded drivers, log if their code-signing certificate has been revoked, in case malware stole one to sign a kernel driver -->

	<!-- <ImageLoad/> --> <!-- Would manually force-on ImageLoad monitoring, even without configuration below. Included only documentation. -->
	<!-- <ProcessAccessConfig/> --> <!-- Would manually force-on ProcessAccess monitoring, even without configuration below. Included only documentation. -->
	<!-- <PipeMonitoringConfig/> --> <!-- Would manually force-on PipeCreated / PipeConnected events, even without configuration below. Included only documentation. -->

	<EventFiltering>

	<!--SYSMON EVENT ID 1 : PROCESS CREATION [ProcessCreate]-->
		<!--COMMENT:	All process launched will be included, except for what matches a rule below. It's best to be as specific as possible, to
			avoid user-mode executables imitating other process names to avoid logging, or if malware drops files in an existing directory.
			Ultimately, you must weigh CPU time checking many detailed rules, against the risk of malware exploiting the blindness created.
			Beware of Masquerading, where attackers imitate the names and paths of legitimate tools. Ideally, you'd use both file path and
			code signatures to validate, but Sysmon does not support that. Look into Windows Device Guard for whitelisting support. -->

		<!--DATA: UtcTime, ProcessGuid, ProcessID, Image, FileVersion, Description, Product, Company, CommandLine, CurrentDirectory, User, LogonGuid, LogonId, TerminalSessionId, IntegrityLevel, Hashes, ParentProcessGuid, ParentProcessId, ParentImage, ParentCommandLine-->
		<ProcessCreate onmatch="exclude">
			<!--SECTION: Microsoft Windows-->
			<CommandLine condition="begin with">C:\Windows\system32\DllHost.exe /Processid</CommandLine> <!--Microsoft:Windows-->
			<CommandLine condition="is">C:\Windows\system32\SearchIndexer.exe /Embedding</CommandLine> <!--Microsoft:Windows: Search Indexer-->
			<Image condition="is">C:\Windows\system32\CompatTelRunner.exe</Image> <!--Microsoft:Windows: Customer Experience Improvement-->
			<Image condition="is">C:\Windows\system32\audiodg.exe</Image> <!--Microsoft:Windows: Launched constantly-->
			<Image condition="is">C:\Windows\system32\conhost.exe</Image> <!--Microsoft:Windows: Command line interface host process-->
			<Image condition="is">C:\Windows\system32\musNotification.exe</Image> <!--Microsoft:Windows: Update pop-ups-->
			<Image condition="is">C:\Windows\system32\musNotificationUx.exe</Image> <!--Microsoft:Windows: Update pop-ups-->
			<Image condition="is">C:\Windows\system32\powercfg.exe</Image> <!--Microsoft:Power configuration management-->
			<Image condition="is">C:\Windows\system32\sndVol.exe</Image> <!--Microsoft:Windows: Volume control-->
			<Image condition="is">C:\Windows\system32\sppsvc.exe</Image> <!--Microsoft:Windows: Software Protection Service-->
			<Image condition="is">C:\Windows\system32\wbem\WmiApSrv.exe</Image> <!--Microsoft:Windows: WMI performance adapter host process-->
			<Image condition="is">C:\Windows\System32\plasrv.exe</Image> <!--Microsoft:Windows: Performance Logs and Alerts DCOM Server-->
			<Image condition="is">C:\Windows\System32\wifitask.exe</Image> <!--Microsoft:Windows: Wireless Background Task-->
			<Image condition="is">C:\Program Files (x86)\Common Files\microsoft shared\ink\TabTip32.exe</Image> <!--Microsoft:Windows: Touch Keyboard and Handwriting Panel Helper-->
			<Image condition="is">C:\Windows\System32\TokenBrokerCookies.exe</Image> <!--Microsoft:Windows: SSO sign-in assistant for MicrosoftOnline.com-->
			<CommandLine condition="is">C:\windows\system32\wermgr.exe -queuereporting</CommandLine> <!--Microsoft:Windows:Windows error reporting/telemetry-->
			<ParentCommandLine condition="is">C:\windows\system32\wermgr.exe -queuereporting</ParentCommandLine> <!--Microsoft:Windows:Windows error reporting/telemetry-->
			<CommandLine condition="begin with"> "C:\Windows\system32\wermgr.exe" "-queuereporting_svc" </CommandLine> <!--Microsoft:Windows:Windows error reporting/telemetry-->
			<CommandLine condition="is">C:\WINDOWS\system32\wermgr.exe -upload</CommandLine> <!--Microsoft:Windows:Windows error reporting/telemetry-->
			<CommandLine condition="is">\SystemRoot\System32\smss.exe</CommandLine> <!--Microsoft:Bootup: Windows Session Manager-->
			<CommandLine condition="is">\??\C:\WINDOWS\system32\autochk.exe *</CommandLine> <!--Microsoft:Bootup: Auto Check Utility-->
			<IntegrityLevel condition="is">AppContainer</IntegrityLevel> <!--Microsoft:Windows: Don't care about sandboxed processes-->
			<ParentCommandLine condition="begin with">%%SystemRoot%%\system32\csrss.exe ObjectDirectory=\Windows</ParentCommandLine> <!--Microsoft:Windows:CommandShell: Triggered when programs use the command shell, but doesn't provide attribution for what caused it-->
			<ParentImage condition="is">C:\Windows\system32\SearchIndexer.exe</ParentImage> <!--Microsoft:Windows:Search: Launches many uninteresting sub-processes-->
			<Image condition="is">C:\Windows\system32\mobsync.exe</Image> <!--Microsoft:Windows: Network file syncing-->
			<CommandLine condition="begin with">C:\Windows\system32\wbem\wmiprvse.exe -Embedding</CommandLine> <!--Microsoft:Windows: WMI provider host-->
			<CommandLine condition="begin with">C:\Windows\system32\wbem\wmiprvse.exe -secured -Embedding</CommandLine> <!--Microsoft:Windows: WMI provider host-->
			<Image condition="is">C:\Windows\system32\SppExtComObj.Exe</Image> <!--Microsoft:Windows: KMS activation-->
			<Image condition="is">C:\Windows\system32\PrintIsolationHost.exe</Image> <!--Microsoft:Windows: Printing-->
			<!--SECTION: Microsoft:Windows:Defender-->
			<Image condition="begin with">C:\Program Files\Windows Defender</Image> <!--Microsoft:Windows:Defender in Win10-->
			<Image condition="is">C:\Windows\system32\MpSigStub.exe</Image> <!--Microsoft:Windows: Microsoft Malware Protection Signature Update Stub-->
			<Image condition="begin with">C:\Windows\SoftwareDistribution\Download\Install\AM_</Image> <!--Microsoft:Defender: Signature updates-->
			<!--SECTION: Microsoft:Windows:svchost-->
				<!--COMMENT: These generally not exclude sub-processes, which may be important. Do not exclude RemoteRegistry or Schedule.-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k appmodel -s StateRepository</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k appmodel</CommandLine> <!--Microsoft:Windows 10-->
			<CommandLine condition="is">C:\WINDOWS\system32\svchost.exe -k appmodel -p -s tiledatamodelsvc</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k camera -s FrameServer</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k dcomlaunch -s LSM</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k dcomlaunch -s PlugPlay</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k defragsvc</CommandLine> <!--Microsoft:Windows defragmentation-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k devicesflow -s DevicesFlowUserSvc</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k imgsvc</CommandLine> <!--Microsoft:The Windows Image Acquisition Service-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localService -s EventSystem</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localService -s bthserv</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localService -s nsi</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localService -s w32Time</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localServiceAndNoImpersonation</CommandLine> <!--Microsoft:Windows: Network services-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localServiceNetworkRestricted -s Dhcp</CommandLine> <!--Microsoft:Windows: Network services-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localServiceNetworkRestricted -s EventLog</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localServiceNetworkRestricted -s TimeBrokerSvc</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localServiceNetworkRestricted -s WFDSConMgrSvc</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localServiceNetworkRestricted</CommandLine> <!--Microsoft:Windows: Network services-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localServiceAndNoImpersonation -s SensrSvc</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localServiceNoNetwork</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localSystemNetworkRestricted -p -s WPDBusEnum</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localSystemNetworkRestricted -p -s fhsvc</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localSystemNetworkRestricted -s DeviceAssociationService</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localSystemNetworkRestricted -s NcbService</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localSystemNetworkRestricted -s SensorService</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localSystemNetworkRestricted -s TabletInputService</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localSystemNetworkRestricted -s UmRdpService</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localSystemNetworkRestricted -s WPDBusEnum</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localSystemNetworkRestricted -s WdiSystemHost</CommandLine> <!--Microsoft:Windows: Diagnostic System Host [ http://www.blackviper.com/windows-services/diagnostic-system-host/ ] -->
			<CommandLine condition="is">C:\WINDOWS\System32\svchost.exe -k LocalSystemNetworkRestricted -p -s WdiSystemHost</CommandLine> <!--Microsoft:Windows: Diagnostic System Host [ http://www.blackviper.com/windows-services/diagnostic-system-host/ ] -->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k localSystemNetworkRestricted</CommandLine> <!--Microsoft:Windows-->
			<CommandLine condition="is">C:\WINDOWS\system32\svchost.exe -k netsvcs -p -s wlidsvc</CommandLine> <!--Microsoft:Windows: Windows Live Sign-In Assistant [ https://www.howtogeek.com/howto/30348/what-are-wlidsvc.exe-and-wlidsvcm.exe-and-why-are-they-running/ ] -->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k netsvcs -p -s ncaSvc</CommandLine> <!--Microsoft:Windows: Network Connectivity Assistant [ http://www.blackviper.com/windows-services/network-connectivity-assistant/ ] -->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k netsvcs -s BDESVC</CommandLine> <!--Microsoft:Windows:Network: BitLocker Drive Encryption-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k netsvcs -s BITS</CommandLine> <!--Microsoft:Windows:Network: Background Intelligent File Transfer (BITS) -->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k netsvcs -s CertPropSvc</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k netsvcs -s DsmSvc</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k netsvcs -s Gpsvc</CommandLine> <!--Microsoft:Windows:Network: Group Policy -->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k netsvcs -s ProfSvc</CommandLine> <!--Microsoft:Windows: Network services-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k netsvcs -s SENS</CommandLine> <!--Microsoft:Windows: Network services-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k netsvcs -s SessionEnv</CommandLine> <!--Microsoft:Windows: Network services-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k netsvcs -s Themes</CommandLine> <!--Microsoft:Windows: Network services-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k netsvcs -s Winmgmt</CommandLine> <!--Microsoft:Windows: Windows Management Instrumentation (WMI) -->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k netsvcs</CommandLine> <!--Microsoft:Windows: Network services-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k networkService -p -s DoSvc</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k networkService -s Dnscache</CommandLine> <!--Microsoft:Windows:Network: DNS caching, other uses -->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k networkService -s LanmanWorkstation</CommandLine> <!--Microsoft:Windows:Network: "Workstation" service, used for SMB file-sharing connections and RDP-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k networkService -s NlaSvc</CommandLine> <!--Microsoft:Windows:Network: Network Location Awareness-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k networkService -s TermService</CommandLine> <!--Microsoft:Windows:Network: Terminal Services (RDP)-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k networkService</CommandLine> <!--Microsoft:Windows: Network services-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k networkServiceNetworkRestricted</CommandLine> <!--Microsoft:Windows: Network services-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k rPCSS</CommandLine> <!--Microsoft:Windows Services-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k secsvcs</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k swprv</CommandLine> <!--Microsoft:Software Shadow Copy Provider-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k unistackSvcGroup</CommandLine> <!--Microsoft:Windows 10-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k utcsvc</CommandLine> <!--Microsoft:Windows Services-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k wbioSvcGroup</CommandLine> <!--Microsoft:Windows Services-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k werSvcGroup</CommandLine> <!--Microsoft:Windows: ErrorReporting-->
			<CommandLine condition="is">C:\WINDOWS\System32\svchost.exe -k wsappx -p -s ClipSVC</CommandLine> <!--Microsoft:Windows:Apps: Client License Service-->
			<CommandLine condition="is">C:\WINDOWS\system32\svchost.exe -k wsappx -p -s AppXSvc</CommandLine> <!--Microsoft:Windows:Apps: AppX Deployment Service-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k wsappx -s ClipSVC</CommandLine> <!--Microsoft:Windows:Apps: Client License Service-->
			<CommandLine condition="is">C:\Windows\system32\svchost.exe -k wsappx</CommandLine> <!--Microsoft:Windows:Apps [ https://www.howtogeek.com/320261/what-is-wsappx-and-why-is-it-running-on-my-pc/ ] -->
			<ParentCommandLine condition="is">C:\Windows\system32\svchost.exe -k netsvcs</ParentCommandLine> <!--Microsoft:Windows: Network services: Spawns Consent.exe-->
			<ParentCommandLine condition="is">C:\Windows\system32\svchost.exe -k localSystemNetworkRestricted</ParentCommandLine> <!--Microsoft:Windows-->
			<!--SECTION: Microsoft:dotNet-->
			<CommandLine condition="begin with">C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe</CommandLine> <!--Microsoft:DotNet-->
			<Image condition="is">C:\Windows\Microsoft.NET\Framework64\v4.0.30319\mscorsvw.exe</Image> <!--Microsoft:DotNet-->
			<Image condition="is">C:\Windows\Microsoft.NET\Framework\v4.0.30319\mscorsvw.exe</Image> <!--Microsoft:DotNet-->
			<Image condition="is">C:\Windows\Microsoft.Net\Framework64\v3.0\WPF\PresentationFontCache.exe</Image> <!--Microsoft:Windows: Font cache service-->
			<ParentCommandLine condition="contains">C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngentask.exe</ParentCommandLine>
			<ParentImage condition="is">C:\Windows\Microsoft.NET\Framework64\v4.0.30319\mscorsvw.exe</ParentImage> <!--Microsoft:DotNet-->
			<ParentImage condition="is">C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngentask.exe</ParentImage> <!--Microsoft:DotNet-->
			<ParentImage condition="is">C:\Windows\Microsoft.NET\Framework\v4.0.30319\mscorsvw.exe</ParentImage> <!--Microsoft:DotNet-->
			<ParentImage condition="is">C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngentask.exe</ParentImage> <!--Microsoft:DotNet: Spawns thousands of ngen.exe processes-->
			<!--SECTION: Microsoft:Office-->
			<Image condition="is">C:\Program Files\Microsoft Office\Office16\MSOSYNC.EXE</Image> <!--Microsoft:Office: Background process for SharePoint/Office365 connectivity-->
			<Image condition="is">C:\Program Files (x86)\Microsoft Office\Office16\MSOSYNC.EXE</Image> <!--Microsoft:Office: Background process for SharePoint/Office365 connectivity-->
			<Image condition="is">C:\Program Files\Microsoft Office\Office15\MSOSYNC.EXE</Image> <!--Microsoft:Office: Background process for SharePoint/Office365 connectivity-->
			<Image condition="is">C:\Program Files\Common Files\Microsoft Shared\OfficeSoftwareProtectionPlatform\OSPPSVC.EXE</Image> <!--Microsoft:Office: Licensing service-->
			<Image condition="is">C:\Program Files\Microsoft Office\Office16\msoia.exe</Image> <!--Microsoft:Office: Telemetry collector-->
			<Image condition="is">C:\Program Files (x86)\Microsoft Office\root\Office16\officebackgroundtaskhandler.exe</Image>
			<!--SECTION: Microsoft:Office:Click2Run-->
			<Image condition="is">C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe</Image> <!--Microsoft:Office: Background process-->
			<ParentImage condition="end with">C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeClickToRun.exe</ParentImage> <!--Microsoft:Office: Background process-->
			<ParentImage condition="is">C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe</ParentImage> <!--Microsoft:Office: Background process-->
			<!--SECTION: Microsoft:Windows: Media player-->
			<Image condition="is">C:\Program Files\Windows Media Player\wmpnscfg.exe</Image> <!--Microsoft:Windows: Windows Media Player Network Sharing Service Configuration Application-->
			<!--SECTION: Google-->
			<CommandLine condition="begin with">"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --type=</CommandLine> <!--Google:Chrome: massive command-line arguments-->
			<CommandLine condition="begin with">"C:\Program Files\Google\Chrome\Application\chrome.exe" --type=</CommandLine> <!--Google:Chrome: massive command-line arguments-->
			<Image condition="begin with">C:\Program Files (x86)\Google\Update\</Image> <!--Google:Chrome:Updater: You should experiment with this line since attackers sometimes hide in this folder-->
			<ParentImage condition="begin with">C:\Program Files (x86)\Google\Update\</ParentImage> <!--Google:Chrome:Updater: You should experiment with this line since attackers sometimes hide in this folder-->
			<!--SECTION: Firefox-->
			<CommandLine condition="begin with">"C:\Program Files\Mozilla Firefox\plugin-container.exe" --channel</CommandLine> <!-- Mozilla:Firefox: Large command-line arguments | Credit @Darkbat91 -->
			<CommandLine condition="begin with">"C:\Program Files (x86)\Mozilla Firefox\plugin-container.exe" --channel</CommandLine> <!-- Mozilla:Firefox: Large command-line arguments | Credit @Darkbat91 -->
			<!--SECTION: Adobe-->
			<CommandLine condition="contains">AcroRd32.exe" /CR </CommandLine> <!--Adobe:AcrobatReader: Uninteresting sandbox subprocess-->
			<CommandLine condition="contains">AcroRd32.exe" --channel=</CommandLine> <!--Adobe:AcrobatReader: Uninteresting sandbox subprocess-->
			<ParentImage condition="end with">C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient\AGSService.exe</ParentImage>
			<!--SECTION: Adobe:Acrobat DC-->
			<Image condition="end with">C:\Program Files (x86)\Adobe\Acrobat DC\Acrobat\AcroCEF\AcroCEF.exe</Image> <!--Adobe:Acrobat: Sandbox subprocess, still evaluating security exposure-->
			<Image condition="end with">C:\Program Files (x86)\Adobe\Acrobat DC\Acrobat\LogTransport2.exe</Image> <!--Adobe: Telemetry [ https://forums.adobe.com/thread/1006701 ] -->
			<!--SECTION: Adobe:Acrobat 2015-->
			<Image condition="end with">C:\Program Files (x86)\Adobe\Acrobat 2015\Acrobat\AcroCEF\AcroCEF.exe</Image> <!--Adobe:Acrobat: Sandbox subprocess, still evaluating security exposure-->
			<Image condition="end with">C:\Program Files (x86)\Adobe\Acrobat 2015\Acrobat\LogTransport2.exe</Image> <!--Adobe: Telemetry [ https://forums.adobe.com/thread/1006701 ] -->
			<!--SECTION: Adobe:Acrobat Reader DC-->
			<Image condition="end with">C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroCEF\RdrCEF.exe</Image> <!--Adobe:AcrobatReader: Sandbox subprocess, still evaluating security exposure-->
			<Image condition="end with">C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\LogTransport2.exe</Image> <!--Adobe: Telemetry [ https://forums.adobe.com/thread/1006701 ] -->
			<!--SECTION: Adobe:Flash-->
			<Image condition="end with">C:\Windows\SysWOW64\Macromed\Flash\FlashPlayerUpdateService.exe</Image> <!--Adobe:Flash: Properly hardened updater, not a risk-->
			<!--SECTION: Adobe:Updater-->
			<Image condition="end with">C:\Program Files (x86)\Common Files\Adobe\ARM\1.0\AdobeARM.exe</Image> <!--Adobe:Updater: Properly hardened updater, not a risk-->
			<ParentImage condition="end with">C:\Program Files (x86)\Common Files\Adobe\ARM\1.0\AdobeARM.exe</ParentImage> <!--Adobe:Updater: Properly hardened updater, not a risk-->
			<Image condition="end with">C:\Program Files (x86)\Common Files\Adobe\ARM\1.0\armsvc.exe</Image> <!--Adobe:Updater: Properly hardened updater, not a risk-->
			<!--SECTION: Adobe:Supporting processes-->
			<Image condition="end with">C:\Program Files (x86)\Adobe\Acrobat DC\Acrobat\AdobeCollabSync.exe</Image>
			<Image condition="end with">C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\HEX\Adobe CEF Helper.exe</Image>
			<Image condition="end with">C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient\AdobeGCClient.exe</Image> <!--Adobe:Creative Cloud-->
			<Image condition="end with">C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\P6\adobe_licutil.exe</Image> <!--Adobe:License utility-->
			<Image condition="end with">C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\P7\adobe_licutil.exe</Image> <!--Adobe:License utility-->
			<ParentImage condition="end with">C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\P7\adobe_licutil.exe</ParentImage> <!--Adobe:License utility-->
			<Image condition="end with">C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\UWA\updaterstartuputility.exe</Image>
			<ParentImage condition="end with">C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\UWA\updaterstartuputility.exe</ParentImage>
			<!--SECTION: Adobe:Creative Cloud-->
			<Image condition="end with">C:\Program Files (x86)\Adobe\Adobe Creative Cloud\ACC\Creative Cloud.exe</Image>
			<ParentImage condition="end with">C:\Program Files (x86)\Adobe\Adobe Creative Cloud\ACC\Creative Cloud.exe</ParentImage>
			<ParentImage condition="end with">C:\Program Files (x86)\Adobe\Adobe Creative Cloud\CCXProcess\CCXProcess.exe</ParentImage>
			<ParentImage condition="end with">C:\Program Files (x86)\Adobe\Adobe Creative Cloud\CoreSync\CoreSync.exe</ParentImage>
			<!--SECTION: Cisco-->
			<ParentImage condition="end with">C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpnagent.exe</ParentImage> <!--Cisco: Calls netsh to change settings on connect-->
			<!--SECTION: Drivers-->
				<!--COMMENT: Attackers sometimes hide themselves in the folders of drivers, be careful to only exclude what is clogging events-->
			<CommandLine condition="begin with">"C:\Program Files\DellTPad\ApMsgFwd.exe" -s{</CommandLine>
			<CommandLine condition="is">C:\Windows\system32\igfxsrvc.exe -Embedding</CommandLine>
			<ParentImage condition="end with">C:\Program Files\DellTPad\HidMonitorSvc.exe</ParentImage>
			<ParentImage condition="end with">C:\Program Files\Realtek\Audio\HDA\RtkAudioService64.exe</ParentImage> <!--Realtek:Driver: routine actions-->
			<!--SECTION: Dropbox-->
			<Image condition="end with">C:\Program Files (x86)\Dropbox\Update\DropboxUpdate.exe</Image> <!--Dropbox:Updater: Lots of command-line arguments-->
			<ParentImage condition="end with">C:\Program Files (x86)\Dropbox\Update\DropboxUpdate.exe</ParentImage>
			<!--SECTION: Dell-->
			<ParentImage condition="is">C:\Program Files (x86)\Dell\CommandUpdate\InvColPC.exe</ParentImage> <!--Dell:CommandUpdate: Detection process-->
			<Image condition="is">C:\Program Files\Dell\SupportAssist\pcdrcui.exe</Image> <!--Dell:SupportAssist: routine actions-->
			<Image condition="is">C:\Program Files\Dell\SupportAssist\koala.exe</Image> <!--Dell:SupportAssist: routine actions-->
			<ParentCommandLine condition="end with">"-outc=C:\ProgramData\Dell\CommandUpdate\inventory.xml" "-logc=C:\ProgramData\Dell\CommandUpdate\scanerrs.xml" "-lang=en" "-enc=UTF-16" </ParentCommandLine>
		</ProcessCreate>

	<!--SYSMON EVENT ID 2 : FILE CREATION TIME RETROACTIVELY CHANGED IN THE FILESYSTEM [FileCreateTime]-->
		<!--COMMENT:	[ https://attack.mitre.org/wiki/Technique/T1099 ] -->

		<!--DATA: UtcTime, ProcessGuid, ProcessId, Image, TargetFilename, CreationUtcTime, PreviousCreationUtcTime-->
		<FileCreateTime onmatch="include">
			<Image condition="begin with">C:\Users</Image> <!--Look for timestomping in user area-->
		</FileCreateTime>

		<FileCreateTime onmatch="exclude">
			<Image condition="image">OneDrive.exe</Image> <!--OneDrive constantly changes file times-->
			<Image condition="image">C:\Windows\system32\backgroundTaskHost.exe</Image>
			<Image condition="contains">setup</Image> <!--Ignore setups-->
			<Image condition="contains">install</Image> <!--Ignore setups-->
			<Image condition="contains">Update\</Image> <!--Ignore setups-->
			<Image condition="end with">redist.exe</Image> <!--Ignore setups-->
			<Image condition="is">msiexec.exe</Image> <!--Ignore setups-->
			<Image condition="is">TrustedInstaller.exe</Image> <!--Ignore setups-->
		</FileCreateTime>

	<!--SYSMON EVENT ID 3 : NETWORK CONNECTION INITIATED [NetworkConnect]-->
		<!--COMMENT:	By default this configuration takes a very conservative approach to network logging, limited to only extremely high-signal events.-->
		<!--COMMENT:	[ https://attack.mitre.org/wiki/Command_and_Control ] [ https://attack.mitre.org/wiki/Exfiltration ] [ https://attack.mitre.org/wiki/Lateral_Movement ] -->
		<!--TECHNICAL:	For the DestinationHostname, Sysmon uses the GetNameInfo API, which will often not have any information, and may just be a CDN. This is NOT reliable for filtering.-->
		<!--TECHNICAL:	For the DestinationPortName, Sysmon uses the GetNameInfo API for the friendly name of ports you see in logs.-->
		<!--TECHNICAL:	These exe do not initiate their connections, and thus includes do not work in this section: BITSADMIN NLTEST-->
		
		<!-- https://www.first.org/resources/papers/conf2017/APT-Log-Analysis-Tracking-Attack-Tools-by-Audit-Policy-and-Sysmon.pdf -->

		<!--DATA: UtcTime, ProcessGuid, ProcessId, Image, User, Protocol, Initiated, SourceIsIpv6, SourceIp, SourceHostname, SourcePort, SourcePortName, DestinationIsIpV6, DestinationIp, DestinationHostname, DestinationPort, DestinationPortName-->
		<NetworkConnect onmatch="include">
			<!--Suspicious sources for network-connecting binaries-->
			<Image condition="begin with">C:\Users</Image> <!--Tools downloaded by users can use other processes for networking, but this is a very valuable indicator.-->
			<Image condition="begin with">C:\ProgramData</Image> <!--Normally, network communications should be sourced from "Program Files" not from ProgramData, something to look at-->
			<Image condition="begin with">C:\Windows\Temp</Image> <!--Suspicious anything would communicate from the system-level temp directory-->
			<!--Suspicious Windows tools-->
			<Image condition="image">at.exe</Image> <!--Microsoft:Windows: Remote task scheduling, removed in Win10 | Credit @ion-storm -->
			<Image condition="image">certutil.exe</Image> <!--Microsoft:Windows: Certificate tool can contact outbound | Credit @ion-storm @FVT [ https://twitter.com/FVT/status/834433734602530817 ] -->
			<Image condition="image">cmd.exe</Image> <!--Microsoft:Windows: Remote command prompt-->
			<Image condition="image">cmstp.exe</Image> <!--Microsoft:Windows: Connection manager profiles can launch executables from WebDAV [ https://twitter.com/NickTyrer/status/958450014111633408 ] | Credit @NickTyrer @Oddvarmoe @KyleHanslovan @subTee -->
			<Image condition="image">cscript.exe</Image> <!--Microsoft:WindowsScriptingHost: | Credit @Cyb3rOps [ https://gist.github.com/Neo23x0/a4b4af9481e01e749409 ] -->
			<Image condition="image">driverquery.exe</Image> <!--Microsoft:Windows: Remote recognisance of system configuration, oudated/vulnerable drivers -->
			<Image condition="image">dsquery.exe</Image> <!--Microsoft: Query Active Directory -->
			<Image condition="image">hh.exe</Image> <!--Microsoft:Windows: HTML Help Executable, opens CHM files -->
			<Image condition="image">infDefaultInstall.exe</Image> <!--Microsoft: [ https://github.com/huntresslabs/evading-autoruns ] | Credit @KyleHanslovan -->
			<Image condition="image">java.exe</Image> <!--Java: Monitor usage of vulnerable application and init from JAR files | Credit @ion-storm -->
			<Image condition="image">javaw.exe</Image> <!--Java: Monitor usage of vulnerable application and init from JAR files -->
			<Image condition="image">javaws.exe</Image> <!--Java: Monitor usage of vulnerable application and init from JAR files -->
			<Image condition="image">mmc.exe</Image> <!--Microsoft:Windows: -->
			<Image condition="image">msbuild.exe</Image> <!--Microsoft:Windows: [ https://www.hybrid-analysis.com/sample/a314f6106633fba4b70f9d6ddbee452e8f8f44a72117749c21243dc93c7ed3ac?environmentId=100 ] -->
			<Image condition="image">mshta.exe</Image> <!--Microsoft:Windows: HTML application executes scripts without IE protections | Credit @ion-storm [ https://en.wikipedia.org/wiki/HTML_Application ] -->
			<Image condition="image">msiexec.exe</Image> <!--Microsoft:Windows: Can install from http:// paths | Credit @vector-sec -->
			<Image condition="image">nbtstat.exe</Image> <!--Microsoft:Windows: NetBIOS statistics, attackers use to enumerate local network -->
			<Image condition="image">net.exe</Image> <!--Microsoft:Windows: Note - May not detect anything, net.exe is a front-end to lower APIs | Credit @ion-storm -->
			<Image condition="image">net1.exe</Image> <!--Microsoft:Windows: Launched by "net.exe", but it may not detect connections either -->
			<Image condition="image">notepad.exe</Image> <!--Microsoft:Windows: [ https://secrary.com/ReversingMalware/CoinMiner/ ] [ https://blog.cobaltstrike.com/2013/08/08/why-is-notepad-exe-connecting-to-the-internet/ ] -->
			<Image condition="image">nslookup.exe</Image> <!--Microsoft:Windows: Retrieve data over DNS -->
			<Image condition="image">powershell.exe</Image> <!--Microsoft:Windows: PowerShell interface-->
			<Image condition="image">qprocess.exe</Image> <!--Microsoft:Windows: [ https://www.first.org/resources/papers/conf2017/APT-Log-Analysis-Tracking-Attack-Tools-by-Audit-Policy-and-Sysmon.pdf ] -->
			<Image condition="image">qwinsta.exe</Image> <!--Microsoft:Windows: Query remote sessions | Credit @ion-storm -->
			<Image condition="image">qwinsta.exe</Image> <!--Microsoft:Windows: Remotely query login sessions on a server or workstation | Credit @ion-storm -->
			<Image condition="image">reg.exe</Image> <!--Microsoft:Windows: Remote Registry editing ability | Credit @ion-storm -->
			<Image condition="image">regsvcs.exe</Image> <!--Microsoft:Windows: [ https://www.hybrid-analysis.com/sample/3f94d7080e6c5b8f59eeecc3d44f7e817b31562caeba21d02ad705a0bfc63d67?environmentId=100 ] -->
			<Image condition="image">regsvr32.exe</Image> <!--Microsoft:Windows: [ https://subt0x10.blogspot.com/2016/04/bypass-application-whitelisting-script.html ] -->
			<Image condition="image">rundll32.exe</Image> <!--Microsoft:Windows: [ https://blog.cobaltstrike.com/2016/07/22/why-is-rundll32-exe-connecting-to-the-internet/ ] -->
			<Image condition="image">rwinsta.exe</Image> <!--Microsoft:Windows: Disconnect remote sessions | Credit @ion-storm -->
			<Image condition="image">sc.exe</Image> <!--Microsoft:Windows: Remotely change Windows service settings | Credit @ion-storm -->
			<Image condition="image">schtasks.exe</Image> <!--Microsoft:Windows: Command-line interface to local and remote tasks -->
			<Image condition="image">taskkill.exe</Image> <!--Microsoft:Windows: Kill processes, has remote ability -->
			<Image condition="image">tasklist.exe</Image> <!--Microsoft:Windows: List processes, has remote ability -->
			<Image condition="image">wmic.exe</Image> <!--Microsoft:WindowsManagementInstrumentation: Credit @Cyb3rOps [ https://gist.github.com/Neo23x0/a4b4af9481e01e749409 ] -->
			<Image condition="image">wscript.exe</Image> <!--Microsoft:WindowsScriptingHost: | Credit @arekfurt -->
			<!--Relevant 3rd Party Tools-->
			<Image condition="image">nc.exe</Image> <!-- Nmap's modern version of netcat [ https://nmap.org/ncat/guide/index.html#ncat-overview ] [ https://securityblog.gr/1517/create-backdoor-in-windows-with-ncat/ ] -->
			<Image condition="image">ncat.exe</Image> <!-- Nmap's modern version of netcat [ https://nmap.org/ncat/guide/index.html#ncat-overview ] [ https://securityblog.gr/1517/create-backdoor-in-windows-with-ncat/ ] -->
			<Image condition="image">psexec.exe</Image> <!--Sysinternals:PsExec client side | Credit @Cyb3rOps -->
			<Image condition="image">psexesvc.exe</Image> <!--Sysinternals:PsExec server side | Credit @Cyb3rOps -->
			<Image condition="image">tor.exe</Image> <!--Tor [ https://www.hybrid-analysis.com/sample/800bf028a23440134fc834efc5c1e02cc70f05b2e800bbc285d7c92a4b126b1c?environmentId=100 ] -->
			<Image condition="image">vnc.exe</Image> <!-- VNC client | Credit @Cyb3rOps -->
			<Image condition="image">vncservice.exe</Image> <!-- VNC server | Credit @Cyb3rOps -->
			<Image condition="image">vncviewer.exe</Image> <!-- VNC client | Credit @Cyb3rOps -->
			<Image condition="image">winexesvc.exe</Image> <!-- Winexe service executable | Credit @Cyb3rOps -->
			<Image condition="image">nmap.exe</Image>
			<Image condition="image">psinfo.exe</Image>
			<!--Ports: Suspicious-->
			<DestinationPort condition="is">22</DestinationPort> <!--SSH protocol, monitor admin connections-->
			<DestinationPort condition="is">23</DestinationPort> <!--Telnet protocol, monitor admin connections, insecure-->
			<DestinationPort condition="is">25</DestinationPort> <!--SMTP mail protocol port, insecure, used by threats-->
			<DestinationPort condition="is">142</DestinationPort> <!--IMAP mail protocol port, insecure, used by threats-->
			<DestinationPort condition="is">3389</DestinationPort> <!--Microsoft:Windows:RDP: Monitor admin connections-->
			<DestinationPort condition="is">5800</DestinationPort> <!--VNC protocol: Monitor admin connections, often insecure-->
			<DestinationPort condition="is">5900</DestinationPort> <!--VNC protocol Monitor admin connections, often insecure-->
			<!--Ports: Proxy-->
			<DestinationPort condition="is">1080</DestinationPort> <!--Socks proxy port | Credit @ion-storm-->
			<DestinationPort condition="is">3128</DestinationPort> <!--Socks proxy port | Credit @ion-storm-->
			<DestinationPort condition="is">8080</DestinationPort> <!--Socks proxy port | Credit @ion-storm-->
			<!--Ports: Tor-->
			<DestinationPort condition="is">1723</DestinationPort> <!--Tor protocol [ https://attack.mitre.org/wiki/Technique/T1090 ] | Credit @ion-storm-->
			<DestinationPort condition="is">4500</DestinationPort> <!--Tor protocol, also triggers on IPsec [ https://attack.mitre.org/wiki/Technique/T1090 ] | Credit @ion-storm-->
			<DestinationPort condition="is">9001</DestinationPort> <!--Tor protocol [ http://www.computerworlduk.com/tutorial/security/tor-enterprise-2016-blocking-malware-darknet-use-rogue-nodes-3633907/ ] -->
			<DestinationPort condition="is">9030</DestinationPort> <!--Tor protocol [ http://www.computerworlduk.com/tutorial/security/tor-enterprise-2016-blocking-malware-darknet-use-rogue-nodes-3633907/ ] -->
		</NetworkConnect>

		<NetworkConnect onmatch="exclude">
			<!--COMMENT: Unfortunately, these exclusions are very broad and easily abused, but it's a limitation of Sysmon rules that they can't be more specific as they're in user folders-->
			<Image condition="image">Spotify.exe</Image> <!--Spotify-->
			<Image condition="end with">AppData\Roaming\Dropbox\bin\Dropbox.exe</Image> <!--Dropbox-->
			<Image condition="image">g2ax_comm_expert.exe</Image> <!--GoToMeeting-->
			<Image condition="image">g2mcomm.exe</Image> <!--GoToMeeting-->
			<!--SECTION: Microsoft-->
			<Image condition="image">OneDrive.exe</Image> <!--Microsoft:OneDrive-->
			<Image condition="image">OneDriveStandaloneUpdater.exe</Image> <!--Microsoft:OneDrive-->
			<Image condition="end with">AppData\Local\Microsoft\Teams\current\Teams.exe</Image> <!--Microsoft: Teams-->
			<DestinationHostname condition="end with">microsoft.com</DestinationHostname> <!--Microsoft:Update delivery-->
			<DestinationHostname condition="end with">microsoft.com.akadns.net</DestinationHostname> <!--Microsoft:Update delivery-->
			<DestinationHostname condition="end with">microsoft.com.nsatc.net</DestinationHostname> <!--Microsoft:Update delivery-->
		</NetworkConnect>

	<!--SYSMON EVENT ID 4 : RESERVED FOR SYSMON STATUS MESSAGES-->

		<!--DATA: UtcTime, State, Version, SchemaVersion-->
		<!--Cannot be filtered.-->

	<!--SYSMON EVENT ID 5 : PROCESS ENDED [ProcessTerminate]-->
		<!--COMMENT:	Useful data in building infection timelines.-->

		<!--DATA: UtcTime, ProcessGuid, ProcessId, Image-->
		<ProcessTerminate onmatch="include">
			<Image condition="begin with">C:\Users</Image> <!--Process terminations by user binaries-->
		</ProcessTerminate>

		<ProcessTerminate onmatch="exclude">
		</ProcessTerminate>

	<!--SYSMON EVENT ID 6 : DRIVER LOADED INTO KERNEL [DriverLoad]-->
		<!--COMMENT:	Because drivers with bugs can be used to escalate to kernel permissions, be extremely selective
			about what you exclude from monitoring. Low event volume, little incentive to exclude.
			[ https://attack.mitre.org/wiki/Technique/T1014 ] -->
		<!--TECHNICAL:	Sysmon will check the signing certificate revocation status of any driver you don't exclude.-->

		<!--DATA: UtcTime, ImageLoaded, Hashes, Signed, Signature, SignatureStatus-->
		<DriverLoad onmatch="exclude">
			<Signature condition="contains">microsoft</Signature> <!--Exclude signed Microsoft drivers-->
			<Signature condition="contains">windows</Signature> <!--Exclude signed Microsoft drivers-->
			<Signature condition="begin with">Intel </Signature> <!--Exclude signed Intel drivers-->
		</DriverLoad>

	<!--SYSMON EVENT ID 7 : DLL (IMAGE) LOADED BY PROCESS [ImageLoad]-->
		<!--COMMENT:	Can cause high system load, disabled by default.-->
		<!--COMMENT:	[ https://attack.mitre.org/wiki/Technique/T1073 ] [ https://attack.mitre.org/wiki/Technique/T1038 ] [ https://attack.mitre.org/wiki/Technique/T1034 ] -->

		<!--DATA: UtcTime, ProcessGuid, ProcessId, Image, ImageLoaded, Hashes, Signed, Signature, SignatureStatus-->
		<ImageLoad onmatch="include">
		</ImageLoad>

	<!--SYSMON EVENT ID 8 : REMOTE THREAD CREATED [CreateRemoteThread]-->
		<!--COMMENT:	Monitor for processes injecting code into other processes. Often used by malware to cloak their actions. Also when Firefox loads Flash.
		[ https://attack.mitre.org/wiki/Technique/T1055 ] -->

		<!--DATA: UtcTime, SourceProcessGuid, SourceProcessId, SourceImage, TargetProcessId, TargetImage, NewThreadId, StartAddress, StartModule, StartFunction-->
		<CreateRemoteThread onmatch="exclude">
			<!--COMMENT: Exclude mostly-safe sources and log anything else.-->
			<SourceImage condition="is">C:\Windows\system32\wbem\WmiPrvSE.exe</SourceImage>
			<SourceImage condition="is">C:\Windows\system32\svchost.exe</SourceImage>
			<SourceImage condition="is">C:\Windows\system32\wininit.exe</SourceImage>
			<SourceImage condition="is">C:\Windows\system32\csrss.exe</SourceImage>
			<SourceImage condition="is">C:\Windows\system32\services.exe</SourceImage>
			<SourceImage condition="is">C:\Windows\system32\winlogon.exe</SourceImage>
			<SourceImage condition="is">C:\Windows\system32\audiodg.exe</SourceImage>
			<StartModule condition="is">C:\Windows\system32\kernel32.dll</StartModule>
			<TargetImage condition="end with">Google\Chrome\Application\chrome.exe</TargetImage>
			<SourceImage condition="is">C:\Program Files (x86)\Webroot\WRSA.exe</SourceImage>
		</CreateRemoteThread>

	<!--SYSMON EVENT ID 9 : RAW DISK ACCESS [RawAccessRead]-->
		<!--EVENT 9: "RawAccessRead detected"-->
		<!--COMMENT:	Can cause high system load, disabled by default.-->
		<!--COMMENT:	Monitor for raw sector-level access to the disk, often used to bypass access control lists or access locked files.
			Disabled by default since including even one entry here activates this component. Reward/performance/rule maintenance decision.
			Encourage you to experiment with this feature yourself. [ https://attack.mitre.org/wiki/Technique/T1067 ] -->
		<!--COMMENT:	You will likely want to set this to a full capture on domain controllers, where no process should be doing raw reads.-->

		<!--DATA: UtcTime, ProcessGuid, ProcessId, Image, Device-->
		<RawAccessRead onmatch="include">
		</RawAccessRead>

	<!--SYSMON EVENT ID 10 : INTER-PROCESS ACCESS [ProcessAccess]-->
		<!--EVENT 10: "Process accessed"-->
		<!--COMMENT:	Can cause high system load, disabled by default.-->
		<!--COMMENT:	Monitor for processes accessing other process' memory.-->

		<!--DATA: UtcTime, SourceProcessGuid, SourceProcessId, SourceThreadId, SourceImage, TargetProcessGuid, TargetProcessId, TargetImage, GrantedAccess, CallTrace-->
		<ProcessAccess onmatch="include">
		</ProcessAccess>

	<!--SYSMON EVENT ID 11 : FILE CREATED [FileCreate]-->
		<!--EVENT 11: "File created"-->
		<!--NOTE:	Other filesystem "minifilters" can make it appear to Sysmon that some files are being written twice. This is not a Sysmon issue, per Mark Russinovich.-->
		<!--NOTE:	You may not see files detected by antivirus. Other filesystem minifilters, like antivirus, can act before Sysmon receives the alert a file was written.-->

		<!--DATA: UtcTime, ProcessGuid, ProcessId, Image, TargetFilename, CreationUtcTime-->
		<FileCreate onmatch="include">
			<TargetFilename condition="contains">\Start Menu</TargetFilename> <!--Microsoft:Windows: Startup links and shortcut modification [ https://attack.mitre.org/wiki/Technique/T1023 ] -->
			<TargetFilename condition="contains">\Startup\</TargetFilename> <!--Microsoft:Office: Changes to user's auto-launched files and shortcuts-->
			<TargetFilename condition="contains">\Content.Outlook\</TargetFilename> <!--Microsoft:Outlook: attachments-->
			<TargetFilename condition="contains">\Downloads\</TargetFilename> <!--Downloaded files. Does not include "Run" files in IE-->
			<TargetFilename condition="end with">.application</TargetFilename> <!--Microsoft:ClickOnce: [ https://blog.netspi.com/all-you-need-is-one-a-clickonce-love-story/ ] -->
			<TargetFilename condition="end with">.appref-ms</TargetFilename> <!--Microsoft:ClickOnce application | Credit @ion-storm -->
			<TargetFilename condition="end with">.bat</TargetFilename> <!--Batch scripting-->
			<TargetFilename condition="end with">.chm</TargetFilename>
			<TargetFilename condition="end with">.cmd</TargetFilename> <!--Batch scripting: Batch scripts can also use the .cmd extension | Credit: @mmazanec -->
			<TargetFilename condition="end with">.cmdline</TargetFilename> <!--Microsoft:dotNet: Executed by cvtres.exe-->
			<TargetFilename condition="end with">.docm</TargetFilename> <!--Microsoft:Office:Word: Macro-->
			<TargetFilename condition="end with">.exe</TargetFilename> <!--Executable-->
			<TargetFilename condition="end with">.jar</TargetFilename> <!--Java applets-->
			<TargetFilename condition="end with">.jnlp</TargetFilename> <!--Java applets-->
			<TargetFilename condition="end with">.jse</TargetFilename> <!--Scripting [ Example: https://www.sophos.com/en-us/threat-center/threat-analyses/viruses-and-spyware/Mal~Phires-C/detailed-analysis.aspx ] -->
			<TargetFilename condition="end with">.hta</TargetFilename> <!--Scripting-->
			<TargetFilename condition="end with">.pptm</TargetFilename> <!--Microsoft:Office:Word: Macro-->
			<TargetFilename condition="end with">.ps1</TargetFilename> <!--PowerShell [ More information: http://www.hexacorn.com/blog/2014/08/27/beyond-good-ol-run-key-part-16/ ] -->
			<TargetFilename condition="end with">.sys</TargetFilename> <!--System driver files-->
			<TargetFilename condition="end with">.scr</TargetFilename> <!--System driver files-->
			<TargetFilename condition="end with">.vbe</TargetFilename> <!--VisualBasicScripting-->
			<TargetFilename condition="end with">.vbs</TargetFilename> <!--VisualBasicScripting-->
			<TargetFilename condition="end with">.xlsm</TargetFilename> <!--Microsoft:Office:Word: Macro-->
			<TargetFilename condition="end with">proj</TargetFilename><!--Microsoft:MSBuild:Script: More information: https://twitter.com/subTee/status/885919612969394177-->
			<TargetFilename condition="end with">.sln</TargetFilename><!--Microsoft:MSBuild:Script: More information: https://twitter.com/subTee/status/885919612969394177-->
			<TargetFilename condition="begin with">C:\Users\Default</TargetFilename> <!--Microsoft:Windows: Changes to default user profile-->
			<TargetFilename condition="begin with">C:\Windows\system32\Drivers</TargetFilename> <!--Microsoft: Drivers dropped here-->
			<TargetFilename condition="begin with">C:\Windows\SysWOW64\Drivers</TargetFilename> <!--Microsoft: Drivers dropped here-->
			<TargetFilename condition="begin with">C:\Windows\system32\GroupPolicy\Machine\Scripts</TargetFilename> <!--Group policy [ More information: http://www.hexacorn.com/blog/2017/01/07/beyond-good-ol-run-key-part-52/ ] -->
			<TargetFilename condition="begin with">C:\Windows\system32\GroupPolicy\User\Scripts</TargetFilename> <!--Group policy [ More information: http://www.hexacorn.com/blog/2017/01/07/beyond-good-ol-run-key-part-52/ ] -->
			<TargetFilename condition="begin with">C:\Windows\system32\Wbem</TargetFilename> <!--Microsoft:WMI: [ More information: http://2014.hackitoergosum.org/slides/day1_WMI_Shell_Andrei_Dumitrescu.pdf ] -->
			<TargetFilename condition="begin with">C:\Windows\SysWOW64\Wbem</TargetFilename> <!--Microsoft:WMI: [ More information: http://2014.hackitoergosum.org/slides/day1_WMI_Shell_Andrei_Dumitrescu.pdf ] -->
			<TargetFilename condition="begin with">C:\Windows\system32\WindowsPowerShell</TargetFilename> <!--Microsoft:Powershell: Look for modifications for persistence [ https://www.malwarearchaeology.com/cheat-sheets ] -->
			<TargetFilename condition="begin with">C:\Windows\SysWOW64\WindowsPowerShell</TargetFilename> <!--Microsoft:Powershell: Look for modifications for persistence [ https://www.malwarearchaeology.com/cheat-sheets ] -->
			<TargetFilename condition="begin with">C:\Windows\Tasks\</TargetFilename> <!--Microsoft:ScheduledTasks [ https://attack.mitre.org/wiki/Technique/T1053 ] -->
			<TargetFilename condition="begin with">C:\Windows\system32\Tasks</TargetFilename> <!--Microsoft:ScheduledTasks [ https://attack.mitre.org/wiki/Technique/T1053 ] -->
			<!--Windows application compatibility-->
			<TargetFilename condition="begin with">C:\Windows\AppPatch\Custom</TargetFilename> <!--Microsoft:Windows: Application compatibility shims [ https://www.fireeye.com/blog/threat-research/2017/05/fin7-shim-databases-persistence.html ] -->
			<TargetFilename condition="contains">VirtualStore</TargetFilename> <!--Microsoft:Windows: UAC virtualization [ https://blogs.msdn.microsoft.com/oldnewthing/20150902-00/?p=91681 ] -->
			<!--Exploitable file names-->
			<TargetFilename condition="end with">.xls</TargetFilename> <!--Legacy Office files are often used for attacks-->
			<TargetFilename condition="end with">.ppt</TargetFilename> <!--Legacy Office files are often used for attacks-->
			<TargetFilename condition="end with">.rft</TargetFilename> <!--RTF files often 0day malware vectors when opened by Office-->
		</FileCreate>

		<FileCreate onmatch="exclude">
			<!--SECTION: Microsoft-->
			<Image condition="is">C:\Program Files (x86)\EMET 5.5\EMET_Service.exe</Image> <!--Microsoft:EMET: Writes to C:\Windows\AppPatch\-->
			<!--SECTION: Microsoft:Office-->
			<TargetFilename condition="is">C:\Windows\System32\Tasks\OfficeSoftwareProtectionPlatform\SvcRestartTask</TargetFilename>
			<!--SECTION: Microsoft:Office:Click2Run-->
			<Image condition="is">C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe</Image> <!-- Microsoft:Office Click2Run-->
			<!--SECTION: Microsoft:Windows-->
			<Image condition="is">C:\Windows\system32\smss.exe</Image> <!-- Microsoft:Windows: Session Manager SubSystem: Creates swapfile.sys,pagefile.sys,hiberfile.sys-->
			<Image condition="is">C:\Windows\system32\CompatTelRunner.exe</Image> <!-- Microsoft:Windows: Windows 10 app, creates tons of cache files-->
			<Image condition="is">\\?\C:\Windows\system32\wbem\WMIADAP.EXE</Image> <!-- Microsoft:Windows: WMI Performance updates-->
			<Image condition="is">C:\Windows\system32\mobsync.exe</Image> <!--Microsoft:Windows: Network file syncing-->
			<TargetFilename condition="begin with">C:\Windows\system32\DriverStore\Temp\</TargetFilename> <!-- Microsoft:Windows: Temp files by DrvInst.exe-->
			<TargetFilename condition="begin with">C:\Windows\system32\wbem\Performance\</TargetFilename> <!-- Microsoft:Windows: Created in wbem by WMIADAP.exe-->
			<TargetFilename condition="end with">WRITABLE.TST</TargetFilename> <!-- Microsoft:Windows: Created in wbem by svchost-->
			<TargetFilename condition="begin with">C:\Windows\Installer\</TargetFilename> <!--Microsoft:Windows:Installer: Ignore MSI installer files caching-->
			<!--SECTION: Microsoft:Windows:Updates-->
			<TargetFilename condition="begin with">C:\$WINDOWS.~BT\Sources\</TargetFilename> <!-- Microsoft:Windows: Feature updates containing lots of .exe and .sys-->
			<Image condition="begin with">C:\Windows\winsxs\amd64_microsoft-windows</Image> <!-- Microsoft:Windows: Windows update-->
			<!--SECTION: Dell-->
			<Image condition="is">C:\Program Files (x86)\Dell\CommandUpdate\InvColPC.exe</Image>
			<!--SECTION: Intel-->
			<Image condition="is">C:\Windows\system32\igfxCUIService.exe</Image> <!--Intel: Drops bat and other files in \Windows in normal operation-->
			<!--SECTION: Adobe-->
			<TargetFilename condition="is">C:\Windows\System32\Tasks\Adobe Acrobat Update Task</TargetFilename>
			<TargetFilename condition="is">C:\Windows\System32\Tasks\Adobe Flash Player Updater</TargetFilename>
		</FileCreate>

	<!--SYSMON EVENT ID 12 & 13 & 14 : REGISTRY MODIFICATION [RegistryEvent]-->
		<!--EVENT 12: "Registry object added or deleted"-->
		<!--EVENT 13: "Registry value set-->
		<!--EVENT 14: "Registry objected renamed"-->

		<!--NOTE:	Windows writes hundreds or thousands of registry keys a minute, so just because you're not changing things, doesn't mean these rules aren't being run.-->
		<!--NOTE:	You do not have to spend a lot of time worrying about performance, CPUs are fast, but it's something to consider. Every rule and condition type has a small cost.-->
		<!--NOTE:	"contains" works by finding the first letter, then matching the second, etc, so the first letters should be as low-occurrence as possible.-->
		<!--NOTE:	[ https://attack.mitre.org/wiki/Technique/T1112 ] -->

		<!--TECHNICAL:	You cannot filter on the "Details" attribute, due to performance issues when very large keys are written, and variety of data formats-->
		<!--TECHNICAL:	Possible prefixes are HKLM, HKCR, and HKU-->
		<!--CRITICAL:	Schema version 3.30 and higher change HKLM\="\REGISTRY\MACHINE\" and HKU\="\REGISTRY\USER\" and HKCR\="\REGISTRY\MACHINE\SOFTWARE\Classes\" and CurrentControlSet="ControlSet001"-->
		<!--CRITICAL:	Due to a bug, Sysmon versions BEFORE 7.01 may not properly log with the new prefix style for registry keys that was originally introduced in schema version 3.30-->
		<!--NOTE:	Because Sysmon runs as a service, it has no filtering ability for, or concept of, HKCU or HKEY_CURRENT_USER. Use "contains" or "end with" to get around this limitation-->

		<!-- ! CRITICAL NOTE !:	It may appear this section is MISSING important entries, but SOME RULES MONITOR MANY KEYS, so look VERY CAREFULLY to see if something is already covered.-->

		<!--DATA: EventType, UtcTime, ProcessGuid, ProcessId, Image, TargetObject, Details (can't filter on), NewName (can't filter on)-->
		<RegistryEvent onmatch="include">
			<!--Autorun or Startups-->
				<!--ADDITIONAL REFERENCE: [ http://www.ghacks.net/2016/06/04/windows-automatic-startup-locations/ ] -->
				<!--ADDITIONAL REFERENCE: [ https://view.officeapps.live.com/op/view.aspx?src=https://arsenalrecon.com/downloads/resources/Registry_Keys_Related_to_Autorun.ods ] -->
				<!--ADDITIONAL REFERENCE: [ http://www.silentrunners.org/launchpoints.html ] -->
				<!--ADDITIONAL REFERENCE: [ https://www.microsoftpressstore.com/articles/article.aspx?p=2762082&seqNum=2 ] -->
			<TargetObject condition="contains">CurrentVersion\Run</TargetObject> <!--Microsoft:Windows: Wildcard for Run keys, including RunOnce, RunOnceEx, RunServices, RunServicesOnce [Also covers terminal server] -->
			<TargetObject condition="contains">Policies\Explorer\Run</TargetObject> <!--Microsoft:Windows: Alternate runs keys | Credit @ion-storm-->
			<TargetObject condition="contains">Group Policy\Scripts</TargetObject> <!--Microsoft:Windows: Group policy scripts-->
			<TargetObject condition="contains">Windows\System\Scripts</TargetObject> <!--Microsoft:Windows: Wildcard for Logon, Loggoff, Shutdown-->
			<TargetObject condition="contains">CurrentVersion\Windows\Load</TargetObject> <!--Microsoft:Windows: [ https://msdn.microsoft.com/en-us/library/jj874148.aspx ] -->
			<TargetObject condition="contains">CurrentVersion\Windows\Run</TargetObject> <!--Microsoft:Windows: [ https://msdn.microsoft.com/en-us/library/jj874148.aspx ] -->
			<TargetObject condition="contains">CurrentVersion\Winlogon\Shell</TargetObject> <!--Microsoft:Windows: [ https://msdn.microsoft.com/en-us/library/ms838576(v=winembedded.5).aspx ] -->
			<TargetObject condition="contains">CurrentVersion\Winlogon\System</TargetObject> <!--Microsoft:Windows [ https://www.exterminate-it.com/malpedia/regvals/zlob-dns-changer/118 ] -->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\Notify</TargetObject> <!--Microsoft:Windows: Autorun location [ https://attack.mitre.org/wiki/Technique/T1004 ] [ https://www.cylance.com/windows-registry-persistence-part-2-the-run-keys-and-search-order ] -->
			<TargetObject condition="begin with">HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\Shell</TargetObject> <!--Microsoft:Windows: [ https://technet.microsoft.com/en-us/library/ee851671.aspx ] -->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\Userinit</TargetObject> <!--Microsoft:Windows: Autorun location [ https://www.cylance.com/windows-registry-persistence-part-2-the-run-keys-and-search-order ] -->
			<TargetObject condition="begin with">HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32</TargetObject> <!--Microsoft:Windows: Legacy driver loading | Credit @ion-storm -->
			<TargetObject condition="begin with">HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\BootExecute</TargetObject> <!--Microsoft:Windows: Autorun | Credit @ion-storm | [ https://www.cylance.com/windows-registry-persistence-part-2-the-run-keys-and-search-order ] -->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug</TargetObject> <!--Microsoft:Windows: Automatic program crash debug program [ https://www.symantec.com/security_response/writeup.jsp?docid=2007-050712-5453-99&tabid=2 ] -->
			<TargetObject condition="contains">UserInitMprLogonScript</TargetObject> <!--Microsoft:Windows: Legacy logon script environment variable [ http://www.hexacorn.com/blog/2014/11/14/beyond-good-ol-run-key-part-18/ ] -->
			<!--Services-->
			<TargetObject condition="end with">\ServiceDll</TargetObject> <!--Microsoft:Windows: Points to a service's DLL [ https://blog.cylance.com/windows-registry-persistence-part-1-introduction-attack-phases-and-windows-services ] -->
			<TargetObject condition="end with">\ServiceManifest</TargetObject> <!--Microsoft:Windows: Manifest pointing to service's DLL [ https://www.geoffchappell.com/studies/windows/win32/services/svchost/index.htm ] -->
			<TargetObject condition="end with">\ImagePath</TargetObject> <!--Microsoft:Windows: Points to a service's EXE [ https://attack.mitre.org/wiki/Technique/T1050 ] -->
			<TargetObject condition="end with">\Start</TargetObject> <!--Microsoft:Windows: Services start mode changes (Disabled, Automatically, Manual)-->
			<!--CLSID launch commands and Default File Association changes-->
			<TargetObject condition="contains">shell\open\command\</TargetObject> <!--Microsoft:Windows: Sensitive sub-key under file associations and CLSID that map to launch command-->
			<TargetObject condition="contains">shell\open\ddeexec\</TargetObject> <!--Microsoft:Windows: Sensitive sub-key under file associations and CLSID that map to launch command-->
			<TargetObject condition="contains">shell\install\command\</TargetObject> <!--Microsoft:Windows: Sensitive sub-key under file associations and CLSID that map to launch command-->
			<TargetObject condition="contains">Explorer\FileExts\</TargetObject> <!--Microsoft:Windows: Changes to file extension mapping-->
			<TargetObject condition="contains">{86C86720-42A0-1069-A2E8-08002B30309D}</TargetObject> <!--Microsoft:Windows: Tooltip handler-->
			<TargetObject condition="contains">exefile</TargetObject> <!--Microsoft:Windows Executable handler, to ensure any changes not generally monitored, for less-common shell command types like "runas"-->
			<!--Windows COM-->
			<TargetObject condition="end with">\InprocServer32\(Default)</TargetObject> <!--Microsoft:Windows:COM Object Hijacking [ https://blog.gdatasoftware.com/2014/10/23941-com-object-hijacking-the-discreet-way-of-persistence ] | Credit @ion-storm -->
			<!--Windows shell visual modifications-->
			<TargetObject condition="end with">\Hidden</TargetObject> <!--Microsoft:Windows:Explorer: Some types of malware try to hide their hidden system files from the user, good signal event -->
			<TargetObject condition="end with">\ShowSuperHidden</TargetObject> <!--Microsoft:Windows:Explorer: Some types of malware try to hide their hidden system files from the user, good signal event [ Example: https://www.symantec.com/security_response/writeup.jsp?docid=2007-061811-4341-99&tabid=2 ] -->
			<TargetObject condition="end with">\HideFileExt</TargetObject> <!--Microsoft:Windows:Explorer: Some malware hides file extensions to make diagnosis/disinfection more daunting to novice users -->
			<!--Windows shell hijack and modifications-->
			<TargetObject condition="contains">Classes\*\</TargetObject> <!--Microsoft:Windows:Explorer: [ http://www.silentrunners.org/launchpoints.html ] -->
			<TargetObject condition="contains">Classes\AllFilesystemObjects\</TargetObject> <!--Microsoft:Windows:Explorer: [ http://www.silentrunners.org/launchpoints.html ] -->
			<TargetObject condition="contains">Classes\Directory\</TargetObject> <!--Microsoft:Windows:Explorer: [ https://stackoverflow.com/questions/1323663/windows-shell-context-menu-option ] -->
			<TargetObject condition="contains">Classes\Drive\</TargetObject> <!--Microsoft:Windows:Explorer: [ https://stackoverflow.com/questions/1323663/windows-shell-context-menu-option ] -->
			<TargetObject condition="contains">Classes\Folder\</TargetObject> <!--Microsoft:Windows:Explorer: ContextMenuHandlers, DragDropHandlers, CopyHookHandlers, [ https://stackoverflow.com/questions/1323663/windows-shell-context-menu-option ] -->
			<TargetObject condition="contains">ContextMenuHandlers\</TargetObject> <!--Microsoft:Windows: [ http://oalabs.openanalysis.net/2015/06/04/malware-persistence-hkey_current_user-shell-extension-handlers/ ] -->
			<TargetObject condition="contains">CurrentVersion\Shell</TargetObject> <!--Microsoft:Windows: Shell Folders, ShellExecuteHooks, ShellIconOverloadIdentifers, ShellServiceObjects, ShellServiceObjectDelayLoad [ http://oalabs.openanalysis.net/2015/06/04/malware-persistence-hkey_current_user-shell-extension-handlers/ ] -->
			<TargetObject condition="begin with">HKLM\Software\Microsoft\Windows\CurrentVersion\explorer\ShellExecuteHooks</TargetObject> <!--Microsoft:Windows: ShellExecuteHooks-->
			<TargetObject condition="begin with">HKLM\Software\Microsoft\Windows\CurrentVersion\explorer\ShellServiceObjectDelayLoad</TargetObject> <!--Microsoft:Windows: ShellExecuteHooks-->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\ShellIconOverlayIdentifiers</TargetObject> <!--Microsoft:Windows: ShellExecuteHooks-->
			<!--AppPaths hijacking-->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\</TargetObject> <!--Microsoft:Windows: Credit to @Hexacorn [ http://www.hexacorn.com/blog/2013/01/19/beyond-good-ol-run-key-part-3/ ] -->
			<!--Terminal service boobytrap-->
			<TargetObject condition="begin with">HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\InitialProgram</TargetObject> <!--Microsoft:Windows:RDP: Note other Terminal Server run keys are handled by another wildcard already-->
			<!--Group Policy integrity-->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\GPExtensions\</TargetObject> <!--Microsoft:Windows: Group Policy internally uses a plug-in architecture that nothing should be modifying-->
			<!--Winsock and Winsock2-->
			<TargetObject condition="begin with">HKLM\SYSTEM\CurrentControlSet\Services\WinSock\</TargetObject> <!--Microsoft:Windows: Wildcard, includes Winsock and Winsock2-->
			<TargetObject condition="end with">\ProxyServer</TargetObject> <!--Microsoft:Windows: System and user proxy server-->
			<!--Credential providers-->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Provider</TargetObject> <!--Wildcard, includes Credential Providers and Credential Provider Filters-->
			<TargetObject condition="begin with">HKLM\SYSTEM\CurrentControlSet\Control\Lsa\</TargetObject> <!-- [ https://attack.mitre.org/wiki/Technique/T1131 ] [ https://attack.mitre.org/wiki/Technique/T1101 ] -->
			<TargetObject condition="begin with">HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SecurityProviders</TargetObject> <!--Microsoft:Windows: Changes to WDigest-UseLogonCredential for password scraping [ https://www.trustedsec.com/april-2015/dumping-wdigest-creds-with-meterpreter-mimikatzkiwi-in-windows-8-1/ ] -->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Netsh</TargetObject> <!--Microsoft:Windows: Netsh helper DLL [ https://attack.mitre.org/wiki/Technique/T1128 ] -->
			<!--Networking-->
			<TargetObject condition="begin with">HKLM\SYSTEM\CurrentControlSet\Control\NetworkProvider\Order\</TargetObject> <!--Microsoft:Windows: Order of network providers that are checked to connect to destination [ https://www.malwarearchaeology.com/cheat-sheets ] -->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles</TargetObject> <!--Microsoft:Windows: | Credit @ion-storm -->
			<TargetObject condition="end with">\EnableFirewall</TargetObject> <!--Microsoft:Windows: Monitor for firewall disablement, all firewall profiles [ https://attack.mitre.org/wiki/Technique/T1089 ] -->
			<TargetObject condition="end with">\DoNotAllowExceptions</TargetObject> <!--Microsoft:Windows: Monitor for firewall disablement, all firewall profiles [ https://attack.mitre.org/wiki/Technique/T1089 ] -->
			<TargetObject condition="begin with">HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\AuthorizedApplications\List</TargetObject> <!--Windows Firewall authorized applications for all networks| Credit @ion-storm -->
			<TargetObject condition="begin with">HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\AuthorizedApplications\List</TargetObject> <!--Windows Firewall authorized applications for domain networks -->
			<!--DLLs that get injected into every process at launch-->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows\Appinit_Dlls\</TargetObject> <!--Microsoft:Windows: Feature disabled by default [ https://attack.mitre.org/wiki/Technique/T1103 ] -->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Windows\Appinit_Dlls\</TargetObject> <!--Microsoft:Windows:  Feature disabled by default [ https://attack.mitre.org/wiki/Technique/T1103 ] -->
			<TargetObject condition="begin with">HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\AppCertDlls\</TargetObject> <!--Microsoft:Windows: Credit to @Hexacorn [ http://www.hexacorn.com/blog/2013/01/19/beyond-good-ol-run-key-part-3/ ] [ https://blog.comodo.com/malware/trojware-win32-trojanspy-volisk-a/ ] -->
			<!--Office-->
			<TargetObject condition="contains">Microsoft\Office\Outlook\Addins\</TargetObject> <!--Microsoft:Office: Outlook add-ins, access to sensitive data and often cause issues-->
			<TargetObject condition="contains">Office Test\</TargetObject> <!-- Microsoft:Office: Persistence method [ http://www.hexacorn.com/blog/2014/04/16/beyond-good-ol-run-key-part-10/ ] | Credit @Hexacorn -->
			<TargetObject condition="contains">Security\Trusted Documents\TrustRecords</TargetObject> <!--Microsoft:Office: Monitor when "Enable editing" or "Enable macros" is used | Credit @OutflankNL | [ https://outflank.nl/blog/2018/01/16/hunting-for-evil-detect-macros-being-executed/ ] -->
			<!--IE-->
			<TargetObject condition="contains">Internet Explorer\Toolbar\</TargetObject> <!--Microsoft:InternetExplorer: Machine and user [ Example: https://www.exterminate-it.com/malpedia/remove-mywebsearch ] -->
			<TargetObject condition="contains">Internet Explorer\Extensions\</TargetObject> <!--Microsoft:InternetExplorer: Machine and user [ Example: https://www.exterminate-it.com/malpedia/remove-mywebsearch ] -->
			<TargetObject condition="contains">Browser Helper Objects\</TargetObject> <!--Microsoft:InternetExplorer: Machine and user [ https://msdn.microsoft.com/en-us/library/bb250436(v=vs.85).aspx ] -->
			<TargetObject condition="end with">\DisableSecuritySettingsCheck</TargetObject>
			<TargetObject condition="end with">\3\1206</TargetObject> <!--Microsoft:InternetExplorer: Malware sometimes assures scripting is on in Internet Zone [ https://support.microsoft.com/en-us/help/182569/internet-explorer-security-zones-registry-entries-for-advanced-users ] -->
			<TargetObject condition="end with">\3\2500</TargetObject> <!--Microsoft:InternetExplorer: Malware sometimes disables Protected Mode in Internet Zone [ https://blog.avast.com/2013/08/12/your-documents-are-corrupted-from-image-to-an-information-stealing-trojan/ ] -->
			<TargetObject condition="end with">\3\1809</TargetObject> <!--Microsoft:InternetExplorer: Malware sometimes disables Pop-up Blocker in Internet Zone [ https://support.microsoft.com/en-us/help/182569/internet-explorer-security-zones-registry-entries-for-advanced-users ] -->
			<!--Magic registry keys-->
			<TargetObject condition="contains">{AB8902B4-09CA-4bb6-B78D-A8F59079A8D5}\</TargetObject> <!--Microsoft:Windows: Thumbnail cache autostart [ http://blog.trendmicro.com/trendlabs-security-intelligence/poweliks-levels-up-with-new-autostart-mechanism/ ] -->
			<!--Install/Infection artifacts-->
			<TargetObject condition="end with">\UrlUpdateInfo</TargetObject> <!--Microsoft:ClickOnce: Source URL is stored in this value [ https://subt0x10.blogspot.com/2016/12/mimikatz-delivery-via-clickonce-with.html ] -->
			<TargetObject condition="end with">\InstallSource</TargetObject> <!--Microsoft:Windows: Source folder for certain program and component installations-->
			<!--Windows UAC tampering-->
			<TargetObject condition="end with">HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableLUA</TargetObject> <!--Detect: UAC Tampering | Credit @ion-storm -->
			<TargetObject condition="end with">HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\LocalAccountTokenFilterPolicy</TargetObject> <!--Detect: UAC Tampering | Credit @ion-storm -->
			<!--Microsoft Security Center tampering | Credit @ion-storm -->
			<TargetObject condition="end with">HKLM\SOFTWARE\Microsoft\Security Center\AllAlertsDisabled</TargetObject> <!-- [ https://attack.mitre.org/wiki/Technique/T1089 ] -->
			<TargetObject condition="end with">HKLM\SOFTWARE\Microsoft\Security Center\AntiVirusOverride</TargetObject> <!-- [ https://attack.mitre.org/wiki/Technique/T1089 ] -->
			<TargetObject condition="end with">HKLM\SOFTWARE\Microsoft\Security Center\AntiVirusDisableNotify</TargetObject> <!-- [ https://attack.mitre.org/wiki/Technique/T1089 ] -->
			<TargetObject condition="end with">HKLM\SOFTWARE\Microsoft\Security Center\DisableMonitoring</TargetObject> <!-- [ https://attack.mitre.org/wiki/Technique/T1089 ] -->
			<TargetObject condition="end with">HKLM\SOFTWARE\Microsoft\Security Center\FirewallDisableNotify</TargetObject> <!-- [ https://attack.mitre.org/wiki/Technique/T1089 ] -->
			<TargetObject condition="end with">HKLM\SOFTWARE\Microsoft\Security Center\FirewallOverride</TargetObject> <!-- [ https://attack.mitre.org/wiki/Technique/T1089 ] -->
			<TargetObject condition="end with">HKLM\SOFTWARE\Microsoft\Security Center\UacDisableNotify</TargetObject> <!-- [ https://attack.mitre.org/wiki/Technique/T1089 ] -->
			<TargetObject condition="end with">HKLM\SOFTWARE\Microsoft\Security Center\UpdatesDisableNotify</TargetObject> <!-- [ https://attack.mitre.org/wiki/Technique/T1089 ] -->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\HideSCAHealth</TargetObject> <!--Microsoft:Windows:Security Center: Malware sometimes disables [ https://blog.avast.com/2013/08/12/your-documents-are-corrupted-from-image-to-an-information-stealing-trojan/ ] -->
			<!--Windows application compatibility-->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Custom</TargetObject> <!--Microsoft:Windows: AppCompat [ https://www.fireeye.com/blog/threat-research/2017/05/fin7-shim-databases-persistence.html ] -->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\InstalledSDB</TargetObject> <!--Microsoft:Windows: AppCompat [ https://attack.mitre.org/wiki/Technique/T1138 ] -->
			<TargetObject condition="contains">VirtualStore</TargetObject> <!--Microsoft:Windows: Registry virtualization [ https://msdn.microsoft.com/en-us/library/windows/desktop/aa965884(v=vs.85).aspx ] -->
			<!--Windows internals integrity monitoring-->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\</TargetObject> <!--Microsoft:Windows: Malware likes changing IFEO, like adding Debugger to disable antivirus EXE-->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\</TargetObject> <!--Microsoft:Windows: Event log system integrity and ACLs-->
			<TargetObject condition="begin with">HKLM\SYSTEM\CurrentControlSet\Control\Safeboot\</TargetObject> <!--Microsoft:Windows: Services approved to load in safe mode-->
			<TargetObject condition="begin with">HKLM\SYSTEM\CurrentControlSet\Control\Winlogon\</TargetObject> <!--Microsoft:Windows: Providers notified by WinLogon-->
			<TargetObject condition="end with">\FriendlyName</TargetObject> <!--Microsoft:Windows: New devices connected and remembered-->
			<TargetObject condition="is">HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\InProgress\(Default)</TargetObject> <!--Microsoft:Windows: See when WindowsInstaller is engaged, useful for timeline matching with other events-->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Tracing\RASAPI32</TargetObject> <!--Microsoft:Windows: Malware sometimes disables tracing to obfuscate tracks-->
		</RegistryEvent>

		<RegistryEvent onmatch="exclude">
		<!--COMMENT:	Remove low-information noise. Often these hide a procress recreating an empty key and do not hide the values created subsequently.-->
			<!--SECTION: Microsoft binaries-->
			<Image condition="end with">Office\root\integration\integrator.exe</Image> <!--Microsoft:Office: C2R client-->
			<Image condition="is">C:\Windows\system32\backgroundTaskHost.exe</Image> <!--Microsoft:Windows: Changes association registry keys-->
			<Image condition="is">C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeClickToRun.exe</Image> <!--Microsoft:Office: C2R client-->
			<Image condition="is">C:\Program Files\Windows Defender\MsMpEng.exe</Image> <!--Microsoft:Windows:Defender-->
			<Image condition="is">C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\SearchUI.exe</Image> <!--Microsoft:Cortana-->
			<Image condition="is">C:\Program Files (x86)\EMET 5.5\EMET_Service.exe</Image> <!--Microsoft:EMET: Routinely refreshes EMET configuration keys from Group Policy-->
			<!--Misc-->
			<TargetObject condition="end with">Toolbar\WebBrowser</TargetObject> <!--Microsoft:IE: Extraneous activity-->
			<TargetObject condition="end with">Toolbar\WebBrowser\ITBar7Height</TargetObject> <!--Microsoft:IE: Extraneous activity-->
			<TargetObject condition="end with">Toolbar\WebBrowser\ITBar7Layout</TargetObject> <!--Microsoft:IE: Extraneous activity-->
			<TargetObject condition="end with">Toolbar\ShellBrowser\ITBar7Layout</TargetObject> <!--Microsoft:Windows:Explorer: Extraneous activity-->
			<TargetObject condition="end with">Internet Explorer\Toolbar\Locked</TargetObject> <!--Microsoft:Windows:Explorer: Extraneous activity-->
			<TargetObject condition="end with">Toolbar\WebBrowser\{47833539-D0C5-4125-9FA8-0819E2EAAC93}</TargetObject> <!--Microsoft:Windows:Explorer: Extraneous activity-->
			<TargetObject condition="end with">ShellBrowser</TargetObject> <!--Microsoft:InternetExplorer: Noise-->
			<TargetObject condition="end with">\CurrentVersion\Run</TargetObject> <!--Microsoft:Windows: Remove noise from the "\Windows\CurrentVersion\Run" wildcard-->
			<TargetObject condition="end with">\CurrentVersion\RunOnce</TargetObject> <!--Microsoft:Windows: Remove noise from the "\Windows\CurrentVersion\Run" wildcard-->
			<TargetObject condition="end with">\CurrentVersion\App Paths</TargetObject> <!--Microsoft:Windows: Remove noise from the "\Windows\CurrentVersion\App Paths" wildcard-->
			<TargetObject condition="end with">\CurrentVersion\Image File Execution Options</TargetObject> <!--Microsoft:Windows: Remove noise from the "\Windows\CurrentVersion\Image File Execution Options" wildcard-->
			<TargetObject condition="end with">\CurrentVersion\Shell Extensions\Cached</TargetObject> <!--Microsoft:Windows: Remove noise from the "\CurrentVersion\Shell Extensions\Cached" wildcard-->
			<TargetObject condition="end with">\CurrentVersion\Shell Extensions\Approved</TargetObject> <!--Microsoft:Windows: Remove noise from the "\CurrentVersion\Shell Extensions\Approved" wildcard-->
			<TargetObject condition="end with">}\PreviousPolicyAreas</TargetObject> <!--Microsoft:Windows: Remove noise from \Winlogon\GPExtensions by svchost.exe-->
			<TargetObject condition="contains">\Control\WMI\Autologger\</TargetObject> <!--Microsoft:Windows: Remove noise from monitoring "\Start"-->
			<TargetObject condition="end with">HKLM\SYSTEM\CurrentControlSet\Services\UsoSvc\Start</TargetObject> <!--Microsoft:Windows: Remove noise from monitoring "\Start"-->
			<TargetObject condition="end with">\Lsa\OfflineJoin\CurrentValue</TargetObject> <!--Microsoft:Windows: Sensitive value during domain join-->
			<TargetObject condition="end with">\Components\TrustedInstaller\Events</TargetObject> <!--Microsoft:Windows: Remove noise monitoring Winlogon-->
			<TargetObject condition="end with">\Components\TrustedInstaller</TargetObject> <!--Microsoft:Windows: Remove noise monitoring Winlogon-->
			<TargetObject condition="end with">\Components\Wlansvc</TargetObject> <!--Microsoft:Windows: Remove noise monitoring Winlogon-->
			<TargetObject condition="end with">\Components\Wlansvc\Events</TargetObject> <!--Microsoft:Windows: Remove noise monitoring Winlogon-->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\</TargetObject> <!--Microsoft:Windows: Remove noise monitoring installations run as system-->
			<TargetObject condition="end with">\Directory\shellex</TargetObject> <!--Microsoft:Windows: Remove noise monitoring Classes-->
			<TargetObject condition="end with">\Directory\shellex\DragDropHandlers</TargetObject> <!--Microsoft:Windows: Remove noise monitoring Classes-->
			<TargetObject condition="end with">\Drive\shellex</TargetObject> <!--Microsoft:Windows: Remove noise monitoring Classes-->
			<TargetObject condition="end with">\Drive\shellex\DragDropHandlers</TargetObject> <!--Microsoft:Windows: Remove noise monitoring Classes-->
			<TargetObject condition="contains">_Classes\AppX</TargetObject> <!--Microsoft:Windows: Remove noise monitoring "Shell\open\command"--> <!--Win8+-->
			<TargetObject condition="begin with">HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Publishers\</TargetObject> <!--Microsoft:Windows: SvcHost Noise-->
			<Image condition="is">C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\SearchUI.exe</Image> <!--Microsoft:Windows: Remove noise from Windows 10 Cortana | Credit @ion-storm--> <!--Win10-->
			<Image condition="is">C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpnagent.exe</Image>
			<!--Bootup Control noise-->
			<TargetObject condition="end with">HKLM\SYSTEM\CurrentControlSet\Control\Lsa\Audit</TargetObject> <!--Microsoft:Windows:lsass.exe: Boot noise--> <!--Win8+-->
			<TargetObject condition="end with">HKLM\SYSTEM\CurrentControlSet\Control\Lsa\Audit\AuditPolicy</TargetObject> <!--Microsoft:Windows:lsass.exe: Boot noise--> <!--Win8+-->
			<TargetObject condition="end with">HKLM\SYSTEM\CurrentControlSet\Control\Lsa\Audit\PerUserAuditing\System</TargetObject> <!--Microsoft:Windows:lsass.exe: Boot noise--> <!--Win8+-->
			<TargetObject condition="end with">HKLM\SYSTEM\CurrentControlSet\Control\Lsa\LsaPid</TargetObject> <!--Microsoft:Windows:lsass.exe: Boot noise-->
			<TargetObject condition="end with">HKLM\SYSTEM\CurrentControlSet\Control\Lsa\SspiCache</TargetObject> <!--Microsoft:Windows:lsass.exe: Boot noise--> <!--Win8+-->
			<TargetObject condition="end with">HKLM\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Domains</TargetObject> <!--Microsoft:Windows:lsass.exe: Boot noise--> <!--Win8+-->
			<TargetObject condition="end with">HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit</TargetObject> <!--Microsoft:Windows:lsass.exe: Boot noise--> <!--Win8+-->
			<!--Services startup settings noise, some low-risk services routinely change it and this can be ignored-->
			<TargetObject condition="end with">\services\bits\Start</TargetObject> <!--Microsoft:Windows: Remove noise from monitoring "\Start"-->
			<TargetObject condition="end with">\services\clr_optimization_v2.0.50727_32\Start</TargetObject> <!--Microsoft:dotNet: Windows 7-->
			<TargetObject condition="end with">\services\clr_optimization_v2.0.50727_64\Start</TargetObject> <!--Microsoft:dotNet: Windows 7-->
			<TargetObject condition="end with">\services\clr_optimization_v4.0.30319_32\Start</TargetObject> <!--Microsoft:dotNet: Windows 10-->
			<TargetObject condition="end with">\services\clr_optimization_v4.0.30319_64\Start</TargetObject> <!--Microsoft:dotNet: Windows 10-->
			<TargetObject condition="end with">\services\deviceAssociationService\Start</TargetObject> <!--Microsoft:Windows: Remove noise from monitoring "\Start"-->
			<TargetObject condition="end with">\services\fhsvc\Start</TargetObject> <!--Microsoft:Windows: File History Service-->
			<TargetObject condition="end with">\services\nal\Start</TargetObject> <!--Intel: Network adapter diagnostic driver-->
			<TargetObject condition="end with">\services\trustedInstaller\Start</TargetObject> <!--Microsoft:Windows: Remove noise from monitoring "\Start"-->
			<TargetObject condition="end with">\services\tunnel\Start</TargetObject> <!--Microsoft:Windows: Remove noise from monitoring "\Start"-->
			<TargetObject condition="end with">\services\usoSvc\Start</TargetObject> <!--Microsoft:Windows: Remove noise from monitoring "\Start"-->
			<!--FileExts noise filtering-->
			<TargetObject condition="contains">\OpenWithProgids</TargetObject> <!--Microsoft:Windows: Remove noise from monitoring "FileExts"-->
			<TargetObject condition="end with">\OpenWithList</TargetObject> <!--Microsoft:Windows: Remove noise from monitoring "FileExts"-->
			<TargetObject condition="end with">\UserChoice</TargetObject> <!--Microsoft:Windows: Remove noise from monitoring "FileExts"-->
			<TargetObject condition="end with">\UserChoice\ProgId</TargetObject> <!--Microsoft:Windows: Remove noise from monitoring "FileExts"--> <!--Win8+-->
			<TargetObject condition="end with">\UserChoice\Hash</TargetObject> <!--Microsoft:Windows: Remove noise from monitoring "FileExts"--> <!--Win8+-->
			<TargetObject condition="end with">\OpenWithList\MRUList</TargetObject> <!--Microsoft:Windows: Remove noise from monitoring "FileExts"-->
			<TargetObject condition="end with">} 0xFFFF</TargetObject> <!--Microsoft:Windows: Remove noise generated by explorer.exe on monitored ShellCached binary keys--> <!--Win8+-->
			<!--Group Policy noise-->
			<TargetObject condition="end with">HKLM\System\CurrentControlSet\Control\Lsa\Audit\SpecialGroups</TargetObject> <!--Microsoft:Windows: Routinely set through Group Policy, not especially important to log-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Startup</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Startup\0</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Startup\0\PSScriptOrder</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Startup\0\SOM-ID</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Startup\0\GPO-ID</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Startup\0\0\IsPowershell</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Startup\0\0\ExecTime</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0\PSScriptOrder</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0\SOM-ID</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0\GPO-ID</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0\0\IsPowershell</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="end with">SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0\0\ExecTime</TargetObject> <!--Microsoft:Windows:Group Policy: Noise below the actual key while building-->
			<TargetObject condition="contains">\safer\codeidentifiers\0\HASHES\{</TargetObject> <!--Microsoft:Windows: Software Restriction Policies. Can be used to disable security tools, but very noisy to monitor if you use it-->
			<!--SECTION: 3rd party-->
			<Image condition="is">C:\Program Files\WIDCOMM\Bluetooth Software\btwdins.exe</Image> <!--Constantly writes to HKLM-->
			<TargetObject condition="begin with">HKCR\VLC.</TargetObject> <!--VLC update noise-->
			<TargetObject condition="begin with">HKCR\iTunes.</TargetObject> <!--Apple: iTunes update noise-->
		</RegistryEvent>

	<!--SYSMON EVENT ID 15 : ALTERNATE DATA STREAM CREATED [FileCreateStreamHash]-->
		<!--EVENT 15: "File stream created"-->
		<!--COMMENT:	Any files created with an NTFS Alternate Data Stream which match these rules will be hashed and logged.
			[ https://blogs.technet.microsoft.com/askcore/2013/03/24/alternate-data-streams-in-ntfs/ ]
			ADS's are used by browsers and email clients to mark files as originating from the Internet or other foreign sources.
			[ https://textslashplain.com/2016/04/04/downloads-and-the-mark-of-the-web/ ] -->
		<!--NOTE: Other filesystem minifilters can make it appear to Sysmon that some files are being written twice. This is not a Sysmon issue, per Mark Russinovich.-->

		<!--DATA: UtcTime, ProcessGuid, ProcessId, Image, TargetFilename, CreationUtcTime, Hash-->
		<FileCreateStreamHash onmatch="include">
			<TargetFilename condition="contains">Downloads</TargetFilename> <!--Downloaded files. Does not include "Run" files in IE-->
			<TargetFilename condition="contains">Temp\7z</TargetFilename> <!--7zip extractions-->
			<TargetFilename condition="contains">Startup</TargetFilename> <!--ADS startup | Example: [ https://www.hybrid-analysis.com/sample/a314f6106633fba4b70f9d6ddbee452e8f8f44a72117749c21243dc93c7ed3ac?environmentId=100 ] -->
			<TargetFilename condition="end with">.bat</TargetFilename> <!--Batch scripting-->
			<TargetFilename condition="end with">.cmd</TargetFilename> <!--Batch scripting | Credit @ion-storm -->
			<TargetFilename condition="end with">.hta</TargetFilename> <!--Scripting-->
			<TargetFilename condition="end with">.lnk</TargetFilename> <!--Shortcut file | Credit @ion-storm -->
			<TargetFilename condition="end with">.ps1</TargetFilename> <!--PowerShell-->
			<TargetFilename condition="end with">.ps2</TargetFilename> <!--PowerShell-->
			<TargetFilename condition="end with">.reg</TargetFilename> <!--Registry File-->
			<TargetFilename condition="end with">.jse</TargetFilename> <!--Registry File-->
			<TargetFilename condition="end with">.vb</TargetFilename> <!--VisualBasicScripting files-->
			<TargetFilename condition="end with">.vbe</TargetFilename> <!--VisualBasicScripting files-->
			<TargetFilename condition="end with">.vbs</TargetFilename> <!--VisualBasicScripting files-->
		</FileCreateStreamHash>

		<FileCreateStreamHash onmatch="exclude">
		</FileCreateStreamHash>

	<!--SYSMON EVENT ID 16 : SYSMON CONFIGURATION CHANGE-->
		<!--EVENT 16: "Sysmon config state changed"-->
		<!--COMMENT:	This ONLY logs if the hash of the configuration changes. Running "sysmon.exe -c" with the current configuration will not be logged with Event 16-->
		
		<!--DATA: UtcTime, Configuration, ConfigurationFileHash-->
		<!--Cannot be filtered.-->

	<!--SYSMON EVENT ID 17 & 18 : PIPE CREATED / PIPE CONNECTED [PipeEvent]-->
		<!--EVENT 17: "Pipe Created"-->
		<!--EVENT 18: "Pipe Connected"-->

		<!--ADDITIONAL REFERENCE: [ https://www.cobaltstrike.com/help-smb-beacon ] -->
		<!--ADDITIONAL REFERENCE: [ https://blog.cobaltstrike.com/2015/10/07/named-pipe-pivoting/ ] -->

		<!--DATA: UtcTime, ProcessGuid, ProcessId, PipeName, Image-->
		<PipeEvent onmatch="include">
		</PipeEvent>

	<!--SYSMON EVENT ID 19 & 20 & 21 : WMI EVENT MONITORING [WmiEvent]-->
		<!--EVENT 19: "WmiEventFilter activity detected"-->
		<!--EVENT 20: "WmiEventConsumer activity detected"-->
		<!--EVENT 21: "WmiEventConsumerToFilter activity detected"-->

		<!--ADDITIONAL REFERENCE: [ https://www.darkoperator.com/blog/2017/10/15/sysinternals-sysmon-610-tracking-of-permanent-wmi-events ] -->
		<!--ADDITIONAL REFERENCE: [ https://rawsec.lu/blog/posts/2017/Sep/19/sysmon-v610-vs-wmi-persistence/ ] -->

		<!--DATA: EventType, UtcTime, Operation, User, Name, Type, Destination, Consumer, Filter-->
		<WmiEvent onmatch="include">
		</WmiEvent>

	<!--SYSMON EVENT ID 255 : ERROR-->
		<!--"This event is generated when an error occurred within Sysmon. They can happen if the system is under heavy load
			and certain tasked could not be performed or a bug exists in the Sysmon service. You can report any bugs on the
			Sysinternals forum or over Twitter (@markrussinovich)."-->
		<!--Cannot be filtered.-->

	</EventFiltering>
</Sysmon>