// package com.example.flutter_app_playground; // replace "pl.leancode.patrol.example" with your app's package

// import org.junit.Rule;
// import org.junit.runner.RunWith;
// import pl.leancode.patrol.PatrolTestRule;
// import pl.leancode.patrol.PatrolTestRunner;

// @RunWith(PatrolTestRunner.class)
// public class MainActivityTest {
//     @Rule
//     public PatrolTestRule<MainActivity> rule = new PatrolTestRule<>(MainActivity.class);
// }



/// ~~~~~~ Patrol 2.x setup ~~~~~~ ///
package com.example.flutter_app_playground; // replace "pl.leancode.patrol.example" with your app's package

import androidx.test.platform.app.InstrumentationRegistry;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import pl.leancode.patrol.PatrolJUnitRunner;

@RunWith(Parameterized.class)
public class MainActivityTest {
    @Parameters(name = "{0}")
    public static Object[] testCases() {
        PatrolJUnitRunner instrumentation = (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.setUp(MainActivity.class);
        instrumentation.waitForPatrolAppService();
        return instrumentation.listDartTests();
    }

    public MainActivityTest(String dartTestName) {
        this.dartTestName = dartTestName;
    }

    private final String dartTestName;

    @Test
    public void runDartTest() {
        PatrolJUnitRunner instrumentation = (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.runDartTest(dartTestName);
    }
}
