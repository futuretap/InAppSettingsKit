# Makefile to be used as a reference on how to build from command line
# as well as for possible inclusion in Jenkins
# Currently only the test target is maintained and it needs an external application (ios-sim, in brew)
# to run. See below for more information
#
# to run tests from Jenkins, create a new job, configure git,
# and add an excetute shell script build phase which runs
# make test. 
#
# Problem: no test reports in JUnit format are generated
# Solution: use https://github.com/ciryon/OCUnit2JUnit.git and add a "| oc
.PHONY: clean LogicTests ApplicationTests

WORKSPACE = -workspace InAppSettingsKit.xcworkspace
BUILD_OPTIONS = -sdk iphonesimulator -configuration Debug ONLY_ACTIVE_ARCH=NO -arch i386

default:
	echo "There's no default."

clean:
	xcrun xcodebuild $(WORKSPACE) -scheme InAppSettingsKit $(BUILD_OPTIONS) clean
	xcrun xcodebuild $(WORKSPACE) -scheme IASKSampleAppStaticLibrary $(BUILD_OPTIONS) clean

# Logic Tests target
# With the help of a seperate scheme, it's easy to run the logic tests from the command line:

LogicTests:
	xcrun xcodebuild $(WORKSPACE) \
									 -scheme "IASKLogicTests" \
									 $(BUILD_OPTIONS) \
									 TEST_AFTER_BUILD=YES

# Application Tests cannot (as of 2.2.2013) be easily run form the command-line
# Current workaround is:
#  * use the sammple app's test to run IASK ApplicationTests
#  * adjust the run-script phase of the ApplicationTest target
#    check this script, it contains the logic to start a simulator and such
#  * an extra scheme to run the ApplicationTests
ApplicationTests:
	xcrun xcodebuild $(WORKSPACE) \
									 -scheme "IASKApplicationTests" \
									 $(BUILD_OPTIONS) \
									 SL_RUN_UNIT_TESTS=1


test: LogicTests ApplicationTests
