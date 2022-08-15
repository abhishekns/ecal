# Create an auto-incrementing build number.

# Build number file.  Increment if any object file changes.
$(BUILD_NUMBER_FILE):
	@echo $$(($$(cat $(BUILD_NUMBER_FILE)) + 1)) > $(BUILD_NUMBER_FILE)