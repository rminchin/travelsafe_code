import '../screens/homepage.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdviceAndHelplines extends StatefulWidget {
  const AdviceAndHelplines({Key? key}) : super(key: key);

  @override
  AdviceState createState() => AdviceState();
}

class AdviceState extends State<AdviceAndHelplines> {
  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {}

  void _launchSite(String url) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      path: url,
    );
    await launchUrl(launchUri);
  }

  void _backScreen() {
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const HomePage(tab: 4)),
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text("TravelSafe"),
            leading: BackButton(
              color: Colors.white,
              onPressed: _backScreen,
            )),
        body: Center(
          child: Column(children: [
            const Text('Advice and Helplines'),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () => _launchSite(
                    "www.citizensadvice.org.uk/family/gender-violence/rape-and-sexual-assault/"),
                child: Text('Citizens Advice UK',
                    style: Theme.of(context).textTheme.headline6)),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () => _launchSite(
                    "www.nhs.uk/live-well/sexual-health/help-after-rape-and-sexual-assault/"),
                child: Text('NHS UK',
                    style: Theme.of(context).textTheme.headline6)),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () => _launchSite(
                    "www.met.police.uk/advice/advice-and-information/rsa/rape-and-sexual-assault/what-happens-after-you-report-rape-or-sexual-assault/"),
                child: Text('Met Police UK',
                    style: Theme.of(context).textTheme.headline6)),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () =>
                    _launchSite("www.sarsas.org.uk/have-i-been-raped/"),
                child: Text('SARSAS',
                    style: Theme.of(context).textTheme.headline6)),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () => _launchSite(
                    "www.supportline.org.uk/problems/rape-and-sexual-assault/"),
                child: Text('Supportline',
                    style: Theme.of(context).textTheme.headline6)),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () => _launchSite(
                    "www.mind.org.uk/information-support/guides-to-support-and-services/abuse/"),
                child: Text('Mind.org',
                    style: Theme.of(context).textTheme.headline6)),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () =>
                    _launchSite("sexualabusesupport.campaign.gov.uk/"),
                child: Text('Gov.uk',
                    style: Theme.of(context).textTheme.headline6)),
          ]),
        ));
  }
}
