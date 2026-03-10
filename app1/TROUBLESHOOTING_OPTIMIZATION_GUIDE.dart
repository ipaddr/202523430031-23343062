/// TROUBLESHOOTING & OPTIMIZATION GUIDE
/// ====================================
///
/// Common issues & solutions, plus optimization tips

/*

════════════════════════════════════════════════════════════════════════════════
SECTION 1 - COMMON BUILD ERRORS
════════════════════════════════════════════════════════════════════════════════

ERROR: "Failed to connect to the service protocol"

Cause: Emulator/device connection issue
Solution:
  1. flutter clean
  2. Restart emulator
  3. flutter pub get
  4. flutter run -v (verbose mode untuk see details)

Atau:
  adb kill-server
  adb start-server
  flutter run


ERROR: "Gradle build failed"

Cause: Gradle configuration issue
Solution:
  1. flutter clean
  2. cd android
  3. ./gradlew clean (atau gradlew.bat clean di Windows)
  4. cd ..
  5. flutter pub get
  6. flutter run


ERROR: "The method 'flutter' cannot be found"

Cause: Flutter tidak installed atau PATH tidak set
Solution:
  1. Check flutter installed: flutter --version
  2. Add flutter ke PATH:
     Windows: C:\src\flutter\bin
     Mac/Linux: ~/flutter/bin


ERROR: "CocoaPods could not find compatible versions"

Cause: iOS dependencies conflict
Solution:
  1. cd ios
  2. rm Podfile.lock
  3. pod install --repo-update
  4. cd ..
  5. flutter run


ERROR: "Unrecognized class option -XX:+ignoreUnrecognizedVMOptions"

Cause: Java version issue
Solution:
  1. Check Java version: java -version
  2. Recommended: Java 11 or higher
  3. Set JAVA_HOME environment variable
  4. Restart terminal & retry


════════════════════════════════════════════════════════════════════════════════
SECTION 2 - COMMON RUNTIME ERRORS
════════════════════════════════════════════════════════════════════════════════

ERROR: "The following assertion was thrown during build():
         RenderFlex children have non-zero flex but incoming height constraints
         are unbounded"

Cause: Widget layout overflow (Column/Row tanpa height constraints)
Solution:
  Find the problematic Column/Row:
  1. Wrap dengan Expanded() untuk flexible sizing
  2. Wrap dengan SizedBox(height: 300) untuk fixed height
  3. Wrap dengan SingleChildScrollView() untuk scrollable container

Contoh fix:
  // BEFORE (wrong)
  Column(
    children: [
      ListView.builder(...) // Error!
    ],
  )

  // AFTER (correct)
  Column(
    children: [
      Expanded(
        child: ListView.builder(...)
      )
    ],
  )


ERROR: "type 'Null' is not a subtype of type 'String'"

Cause: Null safety violation (accessing nullable value without checking)
Solution:
  1. Identify the nullable variable
  2. Add null check before using:
     if (variable != null) { ... }
  3. Or use null coalescing operator:
     variable ?? defaultValue
  4. Or use null assertion (careful!):
     variable!

Contoh:
  // BEFORE (unsafe)
  String name = user.name;  // user.name bisa null

  // AFTER (safe)
  String name = user.name ?? 'Unknown';
  // atau
  if (user.name != null) {
    String name = user.name!;
  }


ERROR: "NoSuchMethodError: The method 'X' isn't defined for class 'Y'"

Cause: Method/property tidak ada atau typo
Solution:
  1. Check spelling dari method name
  2. Check import statement
  3. Check class definition untuk method
  4. Run: flutter pub get
  5. Run: flutter clean
  6. Restart VS Code


ERROR: "setState() called after dispose()"

Cause: Accessing widget setelah dispose (memory leak)
Solution:
  1. Add mounted check sebelum setState:
     if (mounted) {
       setState(() { ... });
     }
  2. Cancel streams/timers di dispose:
     @override
     void dispose() {
       _subscription?.cancel();
       _controller?.close();
       super.dispose();
     }


ERROR: "Future not awaited"

Cause: Async function dipanggil tanpa await
Solution:
  // BEFORE
  _loadData();  // Warning!

  // AFTER
  await _loadData();
  // atau
  _loadData().then((_) { ... });


════════════════════════════════════════════════════════════════════════════════
SECTION 3 - FIREBASE ERRORS
════════════════════════════════════════════════════════════════════════════════

ERROR: "FirebaseException - [core/not-initialized]"

Cause: Firebase tidak initialized sebelum use
Solution:
  Di main() function add:
  
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  }


ERROR: "Authentication/wrong-password"

Cause: Password incorrect untuk user
Solution:
  1. Show error dialog ke user
  2. Let user retry dengan correct password
  3. Implement password reset feature


ERROR: "Firestore/permission-denied"

Cause: Firestore security rules deny access
Solution:
  1. Check Firebase Console → Firestore → Rules
  2. Make sure rules allow authenticated users:
     
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /notes/{document=**} {
           allow read: if request.auth != null;
           allow write: if request.auth != null;
         }
       }
     }

  3. Publish rules

  Atau allow all during testing (NOT production):
     allow read, write: if true;


ERROR: "Firestore/not-found"

Cause: Document/collection tidak ada
Solution:
  1. Check path correctness
  2. Verify data exists di Firebase Console
  3. Handle null case di code:
     
     if (snapshot.hasData && snapshot.data != null) {
       // Use data
     }


════════════════════════════════════════════════════════════════════════════════
SECTION 4 - BLoC RELATED ERRORS
════════════════════════════════════════════════════════════════════════════════

ERROR: "BlocProvider not found in context"

Cause: BlocProvider tidak wrap widget yang need it
Solution:
  Make sure main.dart has:
  
  MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => NavigationBloc()),
      BlocProvider(create: (_) => DialogBloc()),
      BlocProvider(create: (_) => LoadingBloc()),
    ],
    child: MaterialApp(...),
  )


ERROR: "context.read<BLoC>() called when BLoC not provided"

Cause: BLoC tidak available di context
Solution:
  1. Make sure BlocProvider wrapped
  2. Use context.watch() instead of context.read() saat dalam build()
  3. Use context.read() dalam event handler (not in build())


ERROR: "State tidak update"

Cause: Bloc emit state tapi UI tidak rebuild
Solution:
  1. Check if BlocListener/BlocBuilder properly setup
  2. Make sure state class extends Equatable:
     
     class MyState extends Equatable {
       final String value;
       
       const MyState({required this.value});
       
       @override
       List<Object?> get props => [value];
     }
  
  3. If not using Equatable, override == operator


ERROR: "Multiple events queued"

Cause: Too many events added rapidly
Solution:
  1. Add event debounce untuk search:
     
     StreamBuilder(
       stream: _searchController.stream
         .debounceTime(Duration(milliseconds: 500))
         .listen((query) => bloc.add(SearchNote(query))),
     )
  
  2. Or disable button saat processing:
     onPressed: _isLoading ? null : _handleAction()


════════════════════════════════════════════════════════════════════════════════
SECTION 5 - PERFORMANCE OPTIMIZATION
════════════════════════════════════════════════════════════════════════════════

OPTIMIZATION 1 - Memory Management

Problem: Memory usage terus meningkat
Solution:
  1. Add mounted checks:
     if (mounted) setState(() { ... });
  
  2. Cancel subscriptions saat dispose:
     @override
     void dispose() {
       _subscription?.cancel();
       super.dispose();
     }
  
  3. Remove debug print statements di release build
  
  4. Use const constructors:
     // Good
     const SizedBox(height: 16)
     
     // Bad
     SizedBox(height: 16)


OPTIMIZATION 2 - List Performance

Problem: ListView jank dengan 1000+ items
Solution:
  1. Use ListView.builder (lazy loading):
     ListView.builder(
       itemCount: items.length,
       itemBuilder: (context, index) => ItemCard(items[index]),
     )
  
  2. Add cacheExtent untuk preload:
     ListView.builder(
       cacheExtent: 1000,  // Preload 1000 logical pixel
       ...
     )
  
  3. Use RepaintBoundary untuk expensive widgets:
     RepaintBoundary(
       child: ExpensiveCustomPaint(),
     )


OPTIMIZATION 3 - Image Loading

Problem: Images cause lag
Solution:
  1. Use cached_network_image package:
     CachedNetworkImage(
       imageUrl: url,
       placeholder: (context, url) => Skeleton(),
       errorWidget: (context, url, error) => Icon(Icons.error),
     )
  
  2. Compress images before upload
  
  3. Use appropriate image formats (WebP untuk Android)


OPTIMIZATION 4 - Animation Performance

Problem: Animations janky
Solution:
  1. Use SingleTickerProviderStateMixin untuk better performance:
     class MyScreen extends StatefulWidget {
       @override
       State<MyScreen> createState() => _MyScreenState();
     }
     
     class _MyScreenState extends State<MyScreen> 
         with SingleTickerProviderStateMixin {
       late AnimationController _controller;
       
       @override
       void initState() {
         _controller = AnimationController(
           vsync: this,
           duration: Duration(seconds: 1),
         );
       }
     }
  
  2. Avoid doing heavy work dalam animation callback
  
  3. Use const constructors dalam animated widgets


OPTIMIZATION 5 - Build Performance

Problem: Widget rebuild too frequently
Solution:
  1. Use const constructors:
     Widget build() {
       return Column(
         children: const [
           Text('Static text'),
           SizedBox(height: 16),
         ],
       );
     }
  
  2. Extract small widgets untuk better granularity:
     // Bad: Big build method
     build() {
       return Column(children: [
         Text('...'),
         Button(...),
         List(...),
       ]);
     }
     
     // Good: Small focused widgets
     build() {
       return Column(children: [
         _Header(),
         _ActionBar(),
         _ContentList(),
       ]);
     }
  
  3. Use shouldRebuild() di custom Painter:
     @override
     bool shouldRepaint(CustomPainter oldDelegate) => false;


OPTIMIZATION 6 - Build Size

Problem: APK size > 100MB
Solution:
  1. Remove unused dependencies di pubspec.yaml
  2. Remove unused assets/images
  3. Enable shrinkResources di android/app/build.gradle:
     buildTypes {
       release {
         shrinkResources true
         minifyEnabled true
       }
     }
  4. Use ProGuard untuk code shrinking
  5. Compress images
  6. Use AAB format untuk Play Store (auto-optimization)


════════════════════════════════════════════════════════════════════════════════
SECTION 6 - SECURITY BEST PRACTICES
════════════════════════════════════════════════════════════════════════════════

SECURITY 1 - API Keys

Problem: Hardcoded API keys di code
Solution:
  1. Use environment variables:
     const String apiKey = String.fromEnvironment('API_KEY');
     
     Run: flutter run --dart-define=API_KEY=your_key
  
  2. Or use android/app/local.properties untuk Android:
     flutter build apk --dart-define-from-file=.env
  
  3. Never commit keys di git!


SECURITY 2 - Data Encryption

Problem: Sensitive data stored unencrypted
Solution:
  1. Use flutter_secure_storage untuk passwords:
     final storage = FlutterSecureStorage();
     
     // Save
     await storage.write(
       key: 'password',
       value: encryptedPassword,
     );
     
     // Read
     String? password = await storage.read(key: 'password');
  
  2. Encrypt sensitive data sebelum store


SECURITY 3 - Firebase Security Rules

Problem: Database accessible oleh siapa saja
Solution:
  Configure Firestore rules:
  
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /notes/{userId}/{document=**} {
        allow read: if request.auth.uid == userId;
        allow write: if request.auth.uid == userId;
      }
    }
  }


════════════════════════════════════════════════════════════════════════════════
SECTION 7 - QUICK TIPS
════════════════════════════════════════════════════════════════════════════════

Debugging Tips:
  → flutter run -v  (verbose mode)
  → flutter pub global run devtools  (open DevTools)
  → Use debugPrint() untuk conditional logging
  → Use Debug Breakpoints di VS Code

Testing Tips:
  → flutter test
  → flutter test --coverage
  → Use integration_test package

Performance Profiling:
  → flutter run --profile
  → Open DevTools → Timeline tab
  → Check CPU, Memory, Frames


════════════════════════════════════════════════════════════════════════════════
SECTION 8 - USEFUL VS CODE SHORTCUTS
════════════════════════════════════════════════════════════════════════════════

Ctrl+Shift+P  - Command Palette
Ctrl+P        - Quick file open
F5            - Start debugging
Ctrl+K Ctrl+C - Comment code
Ctrl+K Ctrl+U - Uncomment code
Ctrl+H        - Find & Replace
Alt+↑/↓       - Move line up/down
Ctrl+L        - Select line


════════════════════════════════════════════════════════════════════════════════
CONCLUSION
════════════════════════════════════════════════════════════════════════════════

Aplikasi Anda sekarang siap untuk deployment! 

Summary features yg sudah diintegrasikan:
✅ Clean Architecture (BLoC pattern)
✅ Modern State Management
✅ Professional UI/UX
✅ Firebase Integration
✅ Error Handling
✅ Loading States
✅ Performance Optimization

Next: Follow deployment guide untuk release ke Play Store.

Good luck! 🚀

*/
