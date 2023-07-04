import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  final VoidCallback onAction;

  const SideMenu({
    Key? key,
    required this.onAction,
  }) : super(key: key);

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(
              color: Color(0xFFCAD5DD),
              width: .5,
            ),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      header(),
                      menuContent(),
                      communityReferences(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              applicationVersion(),
            ],
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          widget.onAction();
          //dispatcher(ChangeTabIndexAction(TAB_INDEX_MY_PROFILE));
        },
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Icon(
                    Icons.person,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Full name',
              ),
              const SizedBox(height: 4),
              Text('Email'),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuContent() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFCAD5DD),
            width: .5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            menuItem(
              'Clock',
              Icons.access_alarms,
              () {
                widget.onAction();
              },
            ),
            menuItem(
              'Library',
              Icons.local_library,
              () {
                widget.onAction();
              },
            ),
            menuItem(
              'Community',
              Icons.people,
              () {
                widget.onAction();
              },
            ),
            menuItem(
              'Home',
              Icons.home,
              () async {
                widget.onAction();
                await openEmailChooser();
              },
            ),
            menuItem(
              'Diagrams',
              Icons.bar_chart,
              () async {
                widget.onAction();
              },
            ),
            menuItem(
              'Log out',
              Icons.logout,
              () async {

              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget communityReferences() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          menuItem(
            'A1',
            null,
            () {
              widget.onAction();
            },
          ),
          menuItem(
            'A2',
            null,
            () {
              widget.onAction();

            },
          ),
        ],
      ),
    );
  }

  Widget menuItem(String text, IconData? icon, Function onPress) {
    return InkWell(
      onTap: onPress as void Function()?,
      child: Container(
        height: 44,
        child: Row(
          children: <Widget>[
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                text,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future openEmailChooser() async {

  }

  //TODO extract
  void showConfirmationDialog(String content, Function onYesPress,
      [String? yesText, String? noText]) {
    /*final dialog = GenericDialog(
      content: content,
      onPositiveButtonPress: onYesPress,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => dialog,
    );*/
  }

  //TODO extract to BLoC
  void logoutFromServer() async {
/*    try {
      showLoadingDialog();
      final client = await getNetworkClient();

      try {
        final response = await client.getDio().get('api/logout/');

        dispatcher(PopRouteAction());

        if (response.statusCode == HttpStatus.ok ||
            response.statusCode == HttpStatus.unauthorized) {
          dispatcher(LogoutAction());
        } else {
          var localizations = AppLocalizations.of(context);
          SnackBar snackBar = SnackBar(content: Text(localizations!.errorDuringAddBook));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } on DioError catch (derr) {
        print(derr);
        if (derr.response?.statusCode == HttpStatus.unauthorized) {
          dispatcher(LogoutAction());
        }
      }
    } catch (error) {
      print(error);
    }*/
  }

  Widget applicationVersion() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Version of application 1.0.0',
            textAlign: TextAlign.start,
          ),
        ),
      ),
    );
  }
}
