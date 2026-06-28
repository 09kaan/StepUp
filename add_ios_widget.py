import uuid
import re

def gen_uuid():
    return uuid.uuid4().hex[:24].upper()

def main():
    path = 'ios/Runner.xcodeproj/project.pbxproj'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Generate UUIDs
    target_uuid = gen_uuid()
    config_list_uuid = gen_uuid()
    debug_config_uuid = gen_uuid()
    release_config_uuid = gen_uuid()
    profile_config_uuid = gen_uuid()
    
    sources_phase_uuid = gen_uuid()
    frameworks_phase_uuid = gen_uuid()
    resources_phase_uuid = gen_uuid()
    
    swift_file_ref_uuid = gen_uuid()
    swift_build_file_uuid = gen_uuid()
    
    entitlements_file_ref_uuid = gen_uuid()
    
    appex_file_ref_uuid = gen_uuid()
    appex_build_file_uuid = gen_uuid()
    
    group_uuid = gen_uuid()
    
    copy_files_phase_uuid = gen_uuid()
    
    container_proxy_uuid = gen_uuid()
    target_dependency_uuid = gen_uuid()

    # 1. PBXBuildFile
    build_file_section = f"""		{swift_build_file_uuid} /* FitWalkWidget.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {swift_file_ref_uuid} /* FitWalkWidget.swift */; }};
		{appex_build_file_uuid} /* FitWalkWidgetExtension.appex in Embed Foundation Extensions */ = {{isa = PBXBuildFile; fileRef = {appex_file_ref_uuid} /* FitWalkWidgetExtension.appex */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};"""
    content = content.replace('/* Begin PBXBuildFile section */\n', f'/* Begin PBXBuildFile section */\n{build_file_section}\n')

    # 2. PBXContainerItemProxy
    container_proxy_section = f"""		{container_proxy_uuid} /* PBXContainerItemProxy */ = {{
			isa = PBXContainerItemProxy;
			containerPortal = 97C146E61CF9000F007C117D /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = {target_uuid};
			remoteInfo = FitWalkWidget;
		}};"""
    content = content.replace('/* Begin PBXContainerItemProxy section */\n', f'/* Begin PBXContainerItemProxy section */\n{container_proxy_section}\n')

    # 3. PBXCopyFilesBuildPhase
    copy_files_section = f"""		{copy_files_phase_uuid} /* Embed Foundation Extensions */ = {{
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 13;
			files = (
				{appex_build_file_uuid} /* FitWalkWidgetExtension.appex in Embed Foundation Extensions */,
			);
			name = "Embed Foundation Extensions";
			runOnlyForDeploymentPostprocessing = 0;
		}};"""
    content = content.replace('/* Begin PBXCopyFilesBuildPhase section */\n', f'/* Begin PBXCopyFilesBuildPhase section */\n{copy_files_section}\n')

    # 4. PBXFileReference
    file_ref_section = f"""		{swift_file_ref_uuid} /* FitWalkWidget.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FitWalkWidget.swift; sourceTree = "<group>"; }};
		{entitlements_file_ref_uuid} /* FitWalkWidget.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = FitWalkWidget.entitlements; sourceTree = "<group>"; }};
		{appex_file_ref_uuid} /* FitWalkWidgetExtension.appex */ = {{isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = FitWalkWidgetExtension.appex; sourceTree = BUILT_PRODUCTS_DIR; }};"""
    content = content.replace('/* Begin PBXFileReference section */\n', f'/* Begin PBXFileReference section */\n{file_ref_section}\n')

    # 5. PBXFrameworksBuildPhase
    framework_phase_section = f"""		{frameworks_phase_uuid} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};"""
    content = content.replace('/* Begin PBXFrameworksBuildPhase section */\n', f'/* Begin PBXFrameworksBuildPhase section */\n{framework_phase_section}\n')

    # 6. PBXGroup
    group_section = f"""		{group_uuid} /* FitWalkWidget */ = {{
			isa = PBXGroup;
			children = (
				{swift_file_ref_uuid} /* FitWalkWidget.swift */,
				{entitlements_file_ref_uuid} /* FitWalkWidget.entitlements */,
			);
			path = FitWalkWidget;
			sourceTree = "<group>";
		}};"""
    content = content.replace('/* Begin PBXGroup section */\n', f'/* Begin PBXGroup section */\n{group_section}\n')
    
    # Add to main group
    content = content.replace('97C146E51CF9000F007C117D = {\n			isa = PBXGroup;\n			children = (', f'97C146E51CF9000F007C117D = {{\n			isa = PBXGroup;\n			children = (\n				{group_uuid} /* FitWalkWidget */,')
    
    # Add to Products group
    content = content.replace('97C146EF1CF9000F007C117D /* Products */ = {\n			isa = PBXGroup;\n			children = (', f'97C146EF1CF9000F007C117D /* Products */ = {{\n			isa = PBXGroup;\n			children = (\n				{appex_file_ref_uuid} /* FitWalkWidgetExtension.appex */,')

    # 7. PBXNativeTarget
    target_section = f"""		{target_uuid} /* FitWalkWidget */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {config_list_uuid} /* Build configuration list for PBXNativeTarget "FitWalkWidget" */;
			buildPhases = (
				{sources_phase_uuid} /* Sources */,
				{frameworks_phase_uuid} /* Frameworks */,
				{resources_phase_uuid} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = FitWalkWidget;
			productName = FitWalkWidgetExtension;
			productReference = {appex_file_ref_uuid} /* FitWalkWidgetExtension.appex */;
			productType = "com.apple.product-type.app-extension";
		}};"""
    content = content.replace('/* Begin PBXNativeTarget section */\n', f'/* Begin PBXNativeTarget section */\n{target_section}\n')
    
    # Add copy files phase and target dependency to Runner
    content = content.replace('3B06AD1E1E4923F5004D2608 /* Thin Binary */,', f'3B06AD1E1E4923F5004D2608 /* Thin Binary */,\n				{copy_files_phase_uuid} /* Embed Foundation Extensions */,')
    content = content.replace('dependencies = (\n			);', f'dependencies = (\n				{target_dependency_uuid} /* PBXTargetDependency */,\n			);')

    # 8. PBXProject
    content = content.replace('331C8080294A63A400263BE5 /* RunnerTests */,', f'331C8080294A63A400263BE5 /* RunnerTests */,\n				{target_uuid} /* FitWalkWidget */,')

    # 9. PBXResourcesBuildPhase
    resources_phase_section = f"""		{resources_phase_uuid} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};"""
    content = content.replace('/* Begin PBXResourcesBuildPhase section */\n', f'/* Begin PBXResourcesBuildPhase section */\n{resources_phase_section}\n')

    # 10. PBXSourcesBuildPhase
    sources_phase_section = f"""		{sources_phase_uuid} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{swift_build_file_uuid} /* FitWalkWidget.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};"""
    content = content.replace('/* Begin PBXSourcesBuildPhase section */\n', f'/* Begin PBXSourcesBuildPhase section */\n{sources_phase_section}\n')

    # 11. PBXTargetDependency
    target_dependency_section = f"""		{target_dependency_uuid} /* PBXTargetDependency */ = {{
			isa = PBXTargetDependency;
			target = {target_uuid} /* FitWalkWidget */;
			targetProxy = {container_proxy_uuid} /* PBXContainerItemProxy */;
		}};"""
    content = content.replace('/* Begin PBXTargetDependency section */\n', f'/* Begin PBXTargetDependency section */\n{target_dependency_section}\n')

    # 12. XCBuildConfiguration
    build_config_section = f"""		{debug_config_uuid} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME = WidgetBackground;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CODE_SIGN_ENTITLEMENTS = FitWalkWidget/FitWalkWidget.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEBUG_INFORMATION_FORMAT = dwarf;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = FitWalkWidget;
				INFOPLIST_KEY_NSExtensionPointIdentifier = "com.apple.widgetkit-extension";
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MARKETING_VERSION = 1.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				PRODUCT_BUNDLE_IDENTIFIER = com.kaan.fitwalk.FitWalkWidget;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SKIP_INSTALL = YES;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{release_config_uuid} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME = WidgetBackground;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CODE_SIGN_ENTITLEMENTS = FitWalkWidget/FitWalkWidget.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COPY_PHASE_STRIP = NO;
				CURRENT_PROJECT_VERSION = 1;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = FitWalkWidget;
				INFOPLIST_KEY_NSExtensionPointIdentifier = "com.apple.widgetkit-extension";
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MARKETING_VERSION = 1.0;
				MTL_FAST_MATH = YES;
				PRODUCT_BUNDLE_IDENTIFIER = com.kaan.fitwalk.FitWalkWidget;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SKIP_INSTALL = YES;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_OPTIMIZATION_LEVEL = "-Owholemodule";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
		{profile_config_uuid} /* Profile */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME = WidgetBackground;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CODE_SIGN_ENTITLEMENTS = FitWalkWidget/FitWalkWidget.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COPY_PHASE_STRIP = NO;
				CURRENT_PROJECT_VERSION = 1;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = FitWalkWidget;
				INFOPLIST_KEY_NSExtensionPointIdentifier = "com.apple.widgetkit-extension";
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MARKETING_VERSION = 1.0;
				MTL_FAST_MATH = YES;
				PRODUCT_BUNDLE_IDENTIFIER = com.kaan.fitwalk.FitWalkWidget;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SKIP_INSTALL = YES;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_OPTIMIZATION_LEVEL = "-Owholemodule";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Profile;
		}};"""
    content = content.replace('/* Begin XCBuildConfiguration section */\n', f'/* Begin XCBuildConfiguration section */\n{build_config_section}\n')

    # 13. XCConfigurationList
    config_list_section = f"""		{config_list_uuid} /* Build configuration list for PBXNativeTarget "FitWalkWidget" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{debug_config_uuid} /* Debug */,
				{release_config_uuid} /* Release */,
				{profile_config_uuid} /* Profile */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};"""
    content = content.replace('/* Begin XCConfigurationList section */\n', f'/* Begin XCConfigurationList section */\n{config_list_section}\n')

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print("Widget Extension successfully injected to project.pbxproj")

if __name__ == "__main__":
    main()
