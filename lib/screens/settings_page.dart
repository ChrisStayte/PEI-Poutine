import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _versionBuild;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 0,
      ),
      body: Column(
        children: [
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.envelope),
            title: const Text('Send Message'),
            subtitle: const Text('Am I Missing A Location?'),
            onTap: () async {
              final Uri uri = Uri(
                scheme: 'mailto',
                path: 'peipoutine@chrisstayte.com',
                query: 'subject=App Feedback ($_versionBuild)',
              );

              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          AboutListTile(
            icon: FaIcon(FontAwesomeIcons.fileLines),
            child: Text('License'),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.circleInfo),
            title: Text('Version'),
            trailing: FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: ((context, AsyncSnapshot<PackageInfo> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  PackageInfo packageInfo = snapshot.data!;
                  _versionBuild =
                      '${packageInfo.version} (${packageInfo.buildNumber})';
                  return Text(_versionBuild);
                }
              }),
            ),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.twitter),
            title: const Text('@ChrisStayte'),
            onTap: () async {
              final Uri uri = Uri(
                scheme: 'https',
                path: 'www.twitter.com/ChrisStayte',
              );

              if (await canLaunchUrl(uri)) {
                await launchUrl(uri).catchError(
                  (error) {
                    print(error);
                    return false;
                  },
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacy Policy'),
            onTap: () async {
              final Uri uri = Uri(
                scheme: 'https',
                path: 'www.chrisstayte.app/peipoutine/privacy',
              );

              if (await canLaunchUrl(uri)) {
                await launchUrl(uri).catchError(
                  (error) {
                    print(error);
                    return false;
                  },
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.solidFileLines),
            title: const Text('Terms And Conditions'),
            onTap: () async {
              final Uri uri = Uri(
                scheme: 'https',
                path: 'www.chrisstayte.app/peipoutine/terms',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri).catchError(
                  (error) {
                    print(error);
                    return false;
                  },
                );
              }
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.github),
            title: const Text('Repo'),
            onTap: () async {
              final Uri uri = Uri(
                scheme: 'https',
                path: 'www.github.com/ChrisStayte/PEI-Poutine',
              );

              if (await canLaunchUrl(uri)) {
                await launchUrl(uri).catchError(
                  (error) {
                    if (kDebugMode) {
                      print(error);
                    }

                    return false;
                  },
                );
              }
            },
          ),
          const ListTile(
            leading: Icon(Icons.flutter_dash_outlined),
            title: Text('Made with flutter!'),
          ),
        ],
      ),
    );
  }
}
