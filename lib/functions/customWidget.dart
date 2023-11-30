import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/pages/advisor.dart';
import 'package:fyp/pages/advisorProfile.dart';
import 'package:fyp/pages/budget.dart';
import 'package:fyp/pages/committee.dart';
import 'package:fyp/pages/home.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fyp/pages/proposal.dart';
import 'package:fyp/pages/schedule.dart';
import 'package:fyp/pages/society.dart';
import 'package:fyp/pages/student.dart';
import 'package:fyp/pages/studentOngoingEvent.dart';
import 'package:fyp/pages/studentSociety.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:timelines/timelines.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/pages/login.dart';
import 'package:fyp/pages/profile.dart';
import 'package:fyp/functions/responsive.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? buttonColor;
  final double? fontSize;
  final double? width;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.buttonColor,
    this.fontSize,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: buttonColor,
        minimumSize: width != null ? Size(width!, 0) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class CustomDDL<T> extends StatefulWidget {
  final T? value;
  final String hintText;
  final TextEditingController controller;
  final Function(T?)? onChanged;
  final List<DropdownMenuItem<T>> dropdownItems;
  final String? labelText;
  final bool? screen;

  const CustomDDL({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.dropdownItems,
    required this.value,
    this.onChanged,
    this.labelText,
    this.screen,
  }) : super(key: key);

  @override
  _CustomDDLState<T> createState() => _CustomDDLState<T>();
}

class _CustomDDLState<T> extends State<CustomDDL<T>> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      value: widget.value,
      focusColor: Colors.white,
      onChanged: (T? newValue) {
        setState(() {
          widget.controller.text = newValue?.toString() ?? '';
        });
        if (widget.onChanged != null) {
          widget.onChanged!(newValue);
        }
      },
      items: widget.dropdownItems,
      decoration: InputDecoration(
        labelText: widget.screen == true ? widget.labelText : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
        hintText: widget.hintText,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Colors.blue),
        ),
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final int index;
  final String page;

  const CustomDrawer({
    Key? key,
    this.index = 0,
    this.page = '',
  }) : super(key: key);

  Future<String> getData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userEmail = user?.email;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot data = await firestore
        .collection('user')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();
    if (data.docs.isNotEmpty) {
      QueryDocumentSnapshot documentSnapshot = data.docs.first;

      String docId = documentSnapshot.id;
      if (docId.startsWith('B')) {
        return 'branch head';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getData(),
        builder: (context, snapshot) {
          String role = snapshot.data ?? '';
          return Drawer(
            child: Column(
              children: [
                ListTile(
                    leading: Icon(
                      Icons.dashboard,
                      color: index == 1 ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      'Dashboard',
                      style: TextStyle(
                        color: index == 1 ? Colors.white : Colors.black,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Home(),
                        ),
                      );
                    },
                    tileColor: index == 1 ? Colors.blue : null,
                    shape: const Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(255, 219, 219, 219),
                      ),
                    )),
                if (role != 'branch head')
                  ListTile(
                      leading: Icon(
                        Icons.people,
                        color: index == 2 ? Colors.white : Colors.black,
                      ),
                      title: Text(
                        'Society',
                        style: TextStyle(
                          color: index == 2 ? Colors.white : Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentSociety(),
                          ),
                        );
                      },
                      tileColor: index == 2 ? Colors.blue : Colors.white,
                      shape: const Border(
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 219, 219, 219),
                        ),
                      )),
                if (role == 'branch head')
                  ExpansionTile(
                    collapsedBackgroundColor: index == 2 ? Colors.blue : null,
                    backgroundColor: index == 2 ? Colors.blue : null,
                    iconColor: index == 2 ? Colors.white : Colors.black,
                    collapsedIconColor:
                        index == 2 ? Colors.white : Colors.black,
                    leading: Icon(
                      Icons.people,
                      color: index == 2 ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      'Users',
                      style: TextStyle(
                        color: index == 2 ? Colors.white : Colors.black,
                      ),
                    ),
                    shape: const Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(255, 219, 219, 219),
                      ),
                    ),
                    children: <Widget>[
                      Container(
                        color: Colors.grey[300],
                        child: ListTile(
                          tileColor: Colors.white,
                          title: Text(
                            'Student',
                            style: TextStyle(
                                color: page == 'Student' ? Colors.blue : null),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Student(),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        color: Colors.grey[300],
                        child: ListTile(
                          tileColor: Colors.white,
                          title: Text(
                            'Advisor',
                            style: TextStyle(
                                color: page == 'Advisor' ? Colors.blue : null),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Advisor(),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        color: Colors.grey[300],
                        child: ListTile(
                          tileColor: Colors.white,
                          title: Text(
                            'Society',
                            style: TextStyle(
                                color: page == 'Society' ? Colors.blue : null),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Society(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                if (role != 'branch head')
                  ListTile(
                      leading: Icon(
                        Icons.event,
                        color: index == 3 ? Colors.white : Colors.black,
                      ),
                      title: Text(
                        'Event',
                        style: TextStyle(
                          color: index == 3 ? Colors.white : Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentOngoingEvent(),
                          ),
                        );
                      },
                      tileColor: index == 3 ? Colors.blue : null,
                      shape: const Border(
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 219, 219, 219),
                        ),
                      )),
                if (role != 'branch head')
                  ListTile(
                      leading: Icon(
                        Icons.money,
                        color: index == 4 ? Colors.white : Colors.black,
                      ),
                      title: Text(
                        'Claim',
                        style: TextStyle(
                          color: index == 4 ? Colors.white : Colors.black,
                        ),
                      ),
                      onTap: () {},
                      tileColor: index == 4 ? Colors.blue : null,
                      shape: const Border(
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 219, 219, 219),
                        ),
                      )),
              ],
            ),
          );
        });
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool hiding;
  final Icon? icon;
  final String? Function(String?)? validator;
  final String? errorText;
  final String? prefixText;
  final bool enabled;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final Icon? suffixIcon;
  final int maxLine;
  final List<TextInputFormatter>? inputFormatters;
  final String? labelText;
  final bool? screen;
  final int? maxLength;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.hiding = false,
    this.icon,
    this.validator,
    this.errorText,
    this.prefixText,
    this.enabled = true,
    this.onTap,
    this.onChanged,
    this.suffixIcon,
    this.maxLine = 1,
    this.inputFormatters,
    this.labelText,
    this.screen,
    this.maxLength,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = false;

  @override
  void initState() {
    super.initState();
    obscureText = widget.hiding;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLength != null
          ? MaxLengthEnforcement.enforced
          : MaxLengthEnforcement.none,
      inputFormatters: widget.inputFormatters ?? [],
      style: const TextStyle(color: Colors.black),
      maxLines: widget.maxLine,
      onTap: widget.onTap,
      enabled: widget.enabled,
      controller: widget.controller,
      obscureText: obscureText,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.screen == true ? widget.labelText : null,
        contentPadding: EdgeInsets.symmetric(
            horizontal: 10.0, vertical: widget.maxLine != 1 ? 15.0 : 0),
        prefixText: widget.prefixText,
        hintText: widget.hintText,
        errorText: widget.errorText,
        filled: true,
        fillColor: widget.enabled ? Colors.white : Colors.grey[300],
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.blue,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.red,
          ),
        ),
        disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: Colors.grey)),
        prefixIcon: widget.icon,
        suffixIcon: widget.hiding
            ? IconButton(
                padding: const EdgeInsetsDirectional.only(end: 12.0),
                icon: obscureText
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
              )
            : widget.suffixIcon,
      ),
      validator: widget.validator,
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color.fromARGB(255, 218, 218, 218),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'COPYRIGHT © 2023 TAR UMT. All rights reserved.',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 12,
            ),
          ),
          IconButton(
            onPressed: () async {
              Uri url2 = Uri.parse(
                  'https://www.youtube.com/channel/UCqjsPpVnwjCRT5mgAgFo1ng');
              if (await canLaunchUrl(url2)) {
                await launchUrl(url2);
              } else {
                throw 'Could not launch $url2';
              }
            },
            icon: const FaIcon(FontAwesomeIcons.youtube,
                size: 20, color: Colors.blue),
          ),
          IconButton(
            onPressed: () async {
              Uri url1 = Uri.parse('https://www.facebook.com/tarumtkl');
              if (await canLaunchUrl(url1)) {
                await launchUrl(url1);
              } else {
                throw 'Could not launch $url1';
              }
            },
            icon: const FaIcon(FontAwesomeIcons.facebook,
                size: 20, color: Colors.blue),
          ),
          IconButton(
            onPressed: () async {
              Uri url0 =
                  Uri.parse('https://www.instagram.com/tarumt.official/');
              if (await canLaunchUrl(url0)) {
                await launchUrl(url0);
              } else {
                throw 'Could not launch $url0';
              }
            },
            icon: const FaIcon(FontAwesomeIcons.instagram,
                size: 20, color: Colors.blue),
          ),
          IconButton(
            onPressed: () async {
              Uri url = Uri.parse('https://www.linkedin.com/school/tarumt/');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            icon: const FaIcon(FontAwesomeIcons.linkedin,
                size: 20, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(50);

  Future<String> getData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userEmail = user?.email;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot data = await firestore
        .collection('user')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (data.docs.isNotEmpty) {
      return data.docs.first['name'];
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    LocalStorage storage = LocalStorage('user');

    return FutureBuilder<String>(
      future: getData(),
      builder: (context, snapshot) {
        String name = snapshot.data ?? '';

        return AppBar(
          leading: !Responsive.isDesktop(context)
              ? Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                )
              : null,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              if (Responsive.isDesktop(context))
                Image.asset('lib/Images/logo.png', width: 75, height: 75),
              const SizedBox(width: 8),
              const Text('Society Management System'),
            ],
          ),
          actions: [
            if (Responsive.isDesktop(context))
              Center(
                child: Text('Welcome,\n' + name, textAlign: TextAlign.center),
              ),
            const SizedBox(width: 15),
            IconButton(
              onPressed: () {
                if (storage.getItem('role') == 'student') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Profile(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdvisorProfile(),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.person),
            ),
            const SizedBox(width: 15),
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Login(),
                  ),
                );
              },
              icon: const Icon(Icons.logout),
            ),
            const SizedBox(width: 30),
          ],
        );
      },
    );
  }
}

class NavigationMenu extends StatelessWidget {
  final List<String> buttonTexts;
  final List<Widget> destination;

  const NavigationMenu({
    super.key,
    required this.buttonTexts,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String date =
        '${DateFormat('EEEE').format(now)} ${DateFormat('dd-MM-yyyy').format(now)} ${DateFormat('HH:mm').format(now)}';
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: const Color.fromARGB(255, 238, 238, 238),
      child: Row(
        children: [
          const Icon(Icons.home),
          for (int i = 0; i < buttonTexts.length; i++)
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => destination[i],
                      ),
                    );
                  },
                  child: Text(
                    buttonTexts[i],
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                if (i < buttonTexts.length - 1) const Icon(Icons.chevron_right),
              ],
            ),
          const Spacer(),
          if (!Responsive.isMobile(context)) Text(date),
        ],
      ),
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({Key? key, required this.password})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password Strength: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Icon(
              password.length >= 8 ? Icons.check : Icons.close,
              color: password.length >= 8 ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Password must contains atleast 8 characters'),
          ],
        ),
        Row(
          children: [
            Icon(
              RegExp(r'[A-Z]').hasMatch(password) ? Icons.check : Icons.close,
              color: RegExp(r'[A-Z]').hasMatch(password)
                  ? Colors.green
                  : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Password must contains atleast 1 uppercase characters'),
          ],
        ),
        Row(
          children: [
            Icon(
              RegExp(r'[a-z]').hasMatch(password) ? Icons.check : Icons.close,
              color: RegExp(r'[a-z]').hasMatch(password)
                  ? Colors.green
                  : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Password must contains atleast 1 lowercase characters'),
          ],
        ),
        Row(
          children: [
            Icon(
              RegExp(r'\d').hasMatch(password) ? Icons.check : Icons.close,
              color:
                  RegExp(r'\d').hasMatch(password) ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Password must contains atleast 1 digit'),
          ],
        ),
      ],
    );
  }
}

class TabContainer extends StatelessWidget {
  final List<Widget> children;
  final String selectedEvent;
  final String tab;
  final String form;

  const TabContainer(
      {super.key,
      required this.children,
      required this.selectedEvent,
      required this.tab,
      required this.form});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Proposal(selectedEvent: selectedEvent),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                backgroundColor:
                    tab == 'Pre' ? Colors.white : Colors.grey[200],
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.grey, width: 1.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
              child: const Text('Pre Event'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Schedule(selectedEvent: selectedEvent),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                backgroundColor:
                    tab == 'Post' ? Colors.white : Colors.grey[200],
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.grey, width: 1.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
              child: const Text('Post Event'),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1.0, color: Colors.grey),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Proposal(selectedEvent: selectedEvent),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(16.0),
                              backgroundColor:  form == 'Proposal'? Colors.white : Colors.grey[200],
                              foregroundColor: Colors.black,
                              side: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            ),
                            child: const Text('Proposal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Schedule(selectedEvent: selectedEvent),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(16.0),
                              backgroundColor:  form == 'Schedule'? Colors.white : Colors.grey[200],
                              foregroundColor: Colors.black,
                              side: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            ),
                            child: const Text('Schedule'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrgCommittee(selectedEvent: selectedEvent,),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(16.0),
                              backgroundColor:  form == 'Committee'? Colors.white : Colors.grey[200],
                              foregroundColor: Colors.black,
                              side: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            ),
                            child: const Text('Committee'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Budget(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(16.0),
                              foregroundColor: Colors.black,
                              backgroundColor:  form == 'Budget'? Colors.white : Colors.grey[200],
                              side: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            ),
                            child: const Text('Budget'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(width: 1.0, color: Colors.grey),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: children,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CustomTimeline extends StatelessWidget {
  final String status;
  const CustomTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    List<String> progress = ['Planning', 'Checked', 'Recommended', 'Approved'];
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: Timeline.tileBuilder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            theme: TimelineThemeData(
              direction: Axis.horizontal,
              connectorTheme:
                  const ConnectorThemeData(space: 8.0, thickness: 2.0),
            ),
            builder: TimelineTileBuilder.connected(
              connectionDirection: ConnectionDirection.before,
              itemCount: 4,
              itemExtentBuilder: (_, __) {
                return (MediaQuery.of(context).size.width)/5.0;
              },
              oppositeContentsBuilder: (context, index) {
                return Container();
              },
              contentsBuilder: (context, index) {
                return Column(
                  children: [
                    Text(progress[index]),
                    const SizedBox(height: 10),
                  ],
                );
              },
              indicatorBuilder: (_, index) {
                if (index <= progress.indexOf(status)) {
                  return const DotIndicator(
                    size: 20.0,
                    color: Colors.green,
                  );
                } else {
                  return const OutlinedDotIndicator(
                    borderWidth: 4.0,
                    color: Colors.green,
                  );
                }
              },
              connectorBuilder: (_, index, type) {
                if (index > 0) {
                  return const SolidLineConnector(
                    color: Colors.green,
                  );
                } else {
                  return null;
                }
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomButton(
                width: 150,
                onPressed: status == 'Planning' ? () {} : () {},
                text: status == 'Planning' ? 'Submit' : 'Unsubmit'),
          ],
        ),
      ],
    );
  }
}
