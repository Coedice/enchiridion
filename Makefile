.PHONY: simulate
simulate:
	# Start simulator
	@if [ "$(os)" = "ios" ]; then \
		flutter emulators \
			--launch apple_ios_simulator; \
		sleep 2; \
		flutter run \
			--device-id AEC84582-D415-4049-8E96-E62950AA9982 \
			--suppress-analytics; \
	elif [ "$(os)" = "android" ]; then \
		flutter emulators \
			--launch Pixel_6_Pro_API_33; \
		sleep 10; \
		flutter run \
			--device-id emulator-5554 \
			--suppress-analytics; \
	else \
		echo "Unknown OS: $(os)"; \
	fi

	# Quit simulator
	@$(MAKE) quit_simulators

.PHONY: physical_release
physical_release:
	# Build simulator for physical iPhone
	@flutter run \
		--release \
		--device-id 00008020-0011353E0291002E

.PHONY: physical_debug
physical_debug:
	# Build simulator for physical iPhone
	@flutter run \
		--device-id 00008020-0011353E0291002E

.PHONY: builds
builds:
	flutter build ios
	flutter build apk
	flutter build appbundle
	flutter build bundle
	@open build/app/outputs/bundle/release/

.PHONY: format
format:
	dart fix

.PHONY: test
test: 
	flutter analyze
	flutter test

.PHONY: clean
clean: generate_app_icons quit_simulators
	# Update git
	-@git fetch \
		--prune \
		--tags

	# Clean Flutter
	@flutter clean
	@dart doc

	# Flutter doctor
	@flutter doctor

.PHONY: quit_simulators
quit_simulators:
	# Quit iOS simulator
	@osascript \
		-e 'quit app "Simulator"'

	# Quit Android simulator
	@pkill \
		-x qemu-system-aarch64 || true


.PHONY: generate_app_icons
generate_app_icons:
	# Generate icons
	@dart run flutter_launcher_icons

	# Remove EXIF data
	@exiftool \
		-overwrite_original \
		-All= \
			ios/Runner/Assets.xcassets/AppIcon.appiconset/ \
			android/app/src/main/res/drawable-hdpi/ \
			android/app/src/main/res/drawable-mdpi/ \
			android/app/src/main/res/drawable-xhdpi/ \
			android/app/src/main/res/drawable-xxhdpi/ \
			android/app/src/main/res/drawable-xxxhdpi/ \
			android/app/src/main/res/mipmap-anydpi-v26/ \
			android/app/src/main/res/mipmap-hdpi/ \
			android/app/src/main/res/mipmap-mdpi/ \
			android/app/src/main/res/mipmap-xhdpi/ \
			android/app/src/main/res/mipmap-xxhdpi/ \
			android/app/src/main/res/mipmap-xxxhdpi/