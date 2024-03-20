// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'socket_manager.dart'; // Ensure this path correctly leads to your SocketManager file
import 'user_profile_provider.dart'; // Ensure this path correctly leads to your UserProfileProvider file

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SocketManager(context)),
        ChangeNotifierProvider(create: (context) => NavigationState()),
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyCV',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<NavigationState>(
        builder: (context, navigationState, child) {
          return Navigator(
            pages: navigationState.pages,
            onPopPage: (route, result) {
              if (!route.didPop(result)) {
                return false;
              }
              // Perform additional actions if required when a page pops
              return true;
            },
          );
        },
      ),
    );
  }
}

class NavigationState with ChangeNotifier {
  List<Page<dynamic>> _pages = [const MaterialPage(key: ValueKey('Login'), child: LoginScreen())];

  List<Page<dynamic>> get pages => List.unmodifiable(_pages);

  void goToHomePage() {
    _pages = [const MaterialPage(key: ValueKey('Home'), child: HomePage())];
    notifyListeners();
  }

  void logout() {
    _pages = [const MaterialPage(key: ValueKey('Login'), child: LoginScreen())];
    notifyListeners();
  }
}

Map<String, IconData> iconMap = { 
  'school': Icons.school, 'score': Icons.score, 
  'calculate': Icons.calculate, 'volunteer': Icons.volunteer_activism,
  'trophy': Icons.leaderboard, 'work': Icons.work, 'folder': Icons.folder
  // Add other mappings here 
}; 

IconData getIconData(String iconName) { 
  return iconMap[iconName] ?? Icons.error; // Return a default icon if the name isn't found 
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final socketManager = Provider.of<SocketManager>(context, listen: false);
    socketManager.on('login_response', (data) {
      if (data['success']) {
        var userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
        userProfileProvider.updateUserProfile(data['portfolio']);
        Provider.of<NavigationState>(context, listen: false).goToHomePage();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    });
  }

  void _login() {
    final socketManager = Provider.of<SocketManager>(context, listen: false);
    socketManager.emit('login', {
      'username': _usernameController.text,
      'password': _passwordController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyCV',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Navigator(
        pages: context.watch<NavigationState>().pages,
        onPopPage: (route, result) {
          if (context.read<NavigationState>().pages.length > 1) {
            context.read<NavigationState>().logout();
            return true;
          }
          return false;
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Assuming you have a way to access your SocketManager instance, e.g., via a provider or singleton
    final socketManager = SocketManager(context); // This might be different based on your app's architecture
    socketManager.ensureConnected(); // This seems to be a placeholder method with no implementation

    // Listen to connect and disconnect events
    socketManager.on('connect', (_) => debugPrint('connect'));
    socketManager.on('disconnect', (_) => debugPrint('disconnect'));

    // Handle other socket events as needed
  }

  final List<Widget> _widgetOptions = [
    const HomeScreen(),
    // const SchoolScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyCV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );            
            },
          ),
        ],
      ),
      body: Navigator(
        pages: [
          MaterialPage(
            key: const ValueKey('HomeScreen'),
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
        onPopPage: (route, result) {
          return route.didPop(result);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.preview),
            label: 'Preview',
          ),
          /* BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'School',
          ), */
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Edit',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 62, 27, 73),
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileProvider>(context).userProfile;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // Header with user information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/user_avatar.png'), // replace with your user avatar image
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${userProfile?.name}'),
                      Text('${userProfile?.grade}'),
                      // Add more user details here
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Implement search functionality
                  },
                ),
              ],
            ),
          ),
          // Quick Stats Section
          const QuickStatsSection(),
          // Academics Section
          const WorkExperienceSection(),
          // Volunteer Section
          const VolunteerActivitiesSection(),
          // Work Section
          const WorkExperienceSection(),
          // Extracurriculars Section
          const ExtracurricularActivitiesSection(),
          // Acheivement Section
          const AchievementsSection(),
          // Projects Section
          const ProjectsSection()
          // Add more sections as needed
        ],
      ),
    );
  }
}

class Stat {
  final IconData icon;
  final String title;
  late final String value;

  Stat({required this.icon, required this.title, required this.value});
}

class QuickStatsSection extends StatefulWidget {
  const QuickStatsSection({super.key});

  @override
  QuickStatsSectionState createState() => QuickStatsSectionState();
}

class QuickStatsSectionState extends State<QuickStatsSection> {
  // ... QuickStatsSection implementation
  @override
  Widget build(BuildContext context) {
    List<Stat> stats = [
      Stat(icon: Icons.school, title: "GPA", value: "3.8"),
      Stat(icon: Icons.sports_soccer, title: "Sports", value: "5"),
      // Add other stats here
      // ...
    ];

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Use Row to place text and icon in the same line
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Quick Stats',
                  style: Theme.of(context).textTheme.headlineSmall,
                )
              ],
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              children: stats.map((stat) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(stat.icon),
                      Text(stat.title),
                      Text(stat.value),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class AcademicsSection extends StatefulWidget {
  const AcademicsSection({Key? key}) : super(key: key);

  @override
  AcademicsSectionState createState() => AcademicsSectionState();
}

class AcademicsSectionState extends State<AcademicsSection> {
  void _showEditDialog(BuildContext context, AcademicStat stat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _controller = TextEditingController(text: stat.value);
        return AlertDialog(
          title: Text('Edit ${stat.title}'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Value'),
            keyboardType: TextInputType.text, // Adjust based on the expected input type
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton( child: const Text('Save'), onPressed: () { 
              // Assume _controller is your TextEditingController for the input field in the dialog 
              final String newValue = _controller.text; // Assuming the stat being edited is identified uniquely by a title or some form of ID. 
              // Here, 'statTitle' is a placeholder for how you identify the specific stat being edited. 
              final String statTitle = stat.title; 
              // Assuming your UserProfileProvider has a method to update a specific academic stat, 
              // you would call it here, passing in the necessary identifiers and the new value. 
              Provider.of<UserProfileProvider>(context, listen: false).updateUserAcademicStat(statTitle as int, newValue as AcademicStat); 
              // After updating the stat, you can close the dialog. 
              Navigator.of(context).pop(); // Optionally, if your UI does not automatically update 
              // (though it should if properly using Provider and listening to changes), 
              // you might need to trigger a state update manually. This is typically not necessary when using Provider correctly. 
              }, 
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final academics = userProfileProvider.userProfile?.academics ?? [];

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Academics', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: academics.length,
              itemBuilder: (context, index) {
                final academicStat = academics[index];
                return InkWell(
                  onTap: () => _showEditDialog(context, academicStat),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(getIconData(academicStat.icon)),
                        Text(academicStat.title),
                        Text(academicStat.value),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class VolunteerActivitiesSection extends StatefulWidget {
  const VolunteerActivitiesSection({Key? key}) : super(key: key);

  @override
  VolunteerActivitiesSectionState createState() => VolunteerActivitiesSectionState();
}

class VolunteerActivitiesSectionState extends State<VolunteerActivitiesSection> {

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final volunteeractivities = userProfileProvider.userProfile?.volunteerism ?? [];

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Volunteerism', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: volunteeractivities.length,
              itemBuilder: (context, index) {
                final volunteerStat = volunteeractivities[index];
                return InkWell(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(getIconData(volunteerStat.icon)),
                        Text(volunteerStat.title),
                        Text(volunteerStat.value),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class WorkExperienceSection extends StatefulWidget {
  const WorkExperienceSection({Key? key}) : super(key: key);

  @override
  WorkExperienceState createState() => WorkExperienceState();
}

class WorkExperienceState extends State<WorkExperienceSection> {
  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final workexperience = userProfileProvider.userProfile?.workexperience ?? [];

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Work Experience', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: workexperience.length,
              itemBuilder: (context, index) {
                final workexperienceStat = workexperience[index];
                return InkWell(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(getIconData(workexperienceStat.icon)),
                        Text(workexperienceStat.title),
                        Text(workexperienceStat.value),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ExtracurricularActivitiesSection extends StatefulWidget {
  const ExtracurricularActivitiesSection({Key? key}) : super(key: key);

  @override
  ExtracurricularActivitiesSectionState createState() => ExtracurricularActivitiesSectionState();
}

class ExtracurricularActivitiesSectionState extends State<ExtracurricularActivitiesSection> {
  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final extracurricularactivities = userProfileProvider.userProfile?.extracurricular ?? [];

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Extracurricular Activities', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: extracurricularactivities.length,
              itemBuilder: (context, index) {
                final extracurricularStat = extracurricularactivities[index];
                return InkWell(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(getIconData(extracurricularStat.icon)),
                        Text(extracurricularStat.title),
                        Text(extracurricularStat.value),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AchievementsSection extends StatefulWidget {
  const AchievementsSection({Key? key}) : super(key: key);

  @override
  AchievementsSectionState createState() => AchievementsSectionState();
}

class AchievementsSectionState extends State<AchievementsSection> {
  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final achievements = userProfileProvider.userProfile?.achievements ?? [];

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Achievements', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievementStat = achievements[index];
                return InkWell(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(getIconData(achievementStat.icon)),
                        Text(achievementStat.title),
                        Text(achievementStat.value),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({Key? key}) : super(key: key);

  @override
  ProjectsSectionState createState() => ProjectsSectionState();
}

class ProjectsSectionState extends State<ProjectsSection> {
  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final projects = userProfileProvider.userProfile?.projects ?? [];

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Projects', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final projectsStat = projects[index];
                return InkWell(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(getIconData(projectsStat.icon)),
                        Text(projectsStat.title),
                        Text(projectsStat.value),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    // It's important to delay context-based operations until the build method is called.
    // You might want to load user data here from your provider and then update _formData accordingly
  }

  void _saveForm() {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();
      // Implement your save logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize _formData with the user's current data
    final userProfile = Provider.of<UserProfileProvider>(context).userProfile;
    _formData = {
      "name": userProfile?.name ?? '',
      "grade": userProfile?.grade ?? '',
      // Add other fields as necessary
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              initialValue: _formData['name'],
              decoration: const InputDecoration(labelText: 'Name'),
              onSaved: (value) => _formData['name'] = value ?? '',
              validator: (value) => value?.isEmpty == true ? 'This field cannot be empty' : null,
            ),
            TextFormField(
              initialValue: _formData['grade'],
              decoration: const InputDecoration(labelText: 'Grade'),
              onSaved: (value) => _formData['grade'] = value ?? '',
              validator: (value) => value?.isEmpty == true ? 'This field cannot be empty' : null,
            ),
            // Add more TextFormField widgets for each piece of information you want to be editable
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: ListTile.divideTiles( // Adding dividers between each list item
          context: context,
          tiles: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Account'),
              onTap: () {
                // Navigate to account settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                // Navigate to notification settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Theme'),
              onTap: () {
                // Navigate to theme change settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Privacy'),
              onTap: () {
                // Navigate to privacy settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                // Show app version or about information
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                final socketManager = Provider.of<SocketManager>(context, listen: false);
                socketManager.logout();

                // Navigate to the LoginScreen
                Provider.of<NavigationState>(context, listen: false).logout();              
              },
            ),
          ],
        ).toList(),
      ),
    );
  }
}
              /*ElevatedButton(
        onPressed: () {
          // Correctly access SocketManager instance to emit logout event

        },
        child: const Text('Logout'), 
      ),*/