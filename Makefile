project:
	ruby Helpers/make_project.rb
clean:
	rm -rf Prism.xcodeproj
test:
	swift test | xcpretty -c