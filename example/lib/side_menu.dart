import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  final VoidCallback onAction;

  const SideMenu({
    Key? key,
    required this.onAction,
  }) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(
              color: Color(0xFFCAD5DD),
              width: 0.5,
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
                      _MenuHeader(onPress: widget.onAction),
                      _MenuContent(onPress: widget.onAction),
                      _MenuFooter(onPress: widget.onAction),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              const _AppVersion(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({
    super.key,
    this.onPress,
  });

  final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onPress,
        child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  width: 64,
                  height: 64,
                  color: const Color(0xFFBDBDBD),
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: Color(0xFF8D6E63),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Smith',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'john.smith@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _MenuContent extends StatelessWidget {
  const _MenuContent({
    super.key,
    required this.onPress,
  });

  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFCAD5DD),
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _MenuItem(
              text: 'Library',
              icon: Icons.local_library,
              onPress: onPress,
            ),
            _MenuItem(
              text: 'Community',
              icon: Icons.people,
              onPress: onPress,
            ),
            _MenuItem(
              text: 'Statistics',
              icon: Icons.bar_chart,
              onPress: onPress,
            ),
            _MenuItem(
              text: 'Calendar',
              icon: Icons.calendar_month,
              onPress: onPress,
            ),
            const SizedBox(height: 12),
            _MenuItem(
              text: 'Log out',
              icon: Icons.logout,
              iconColor: Color(0xFF9E9E9E),
              onPress: onPress,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _MenuFooter extends StatelessWidget {
  const _MenuFooter({
    super.key,
    required this.onPress,
  });

  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _MenuItem(
            text: 'FAQ',
            onPress: onPress,
          ),
          _MenuItem(
            text: 'Privacy policy',
            onPress: onPress,
          ),
          _MenuItem(
            text: 'Terms of service',
            onPress: onPress,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    super.key,
    required this.text,
    this.icon,
    this.iconColor,
    required this.onPress,
  });

  final String text;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: SizedBox(
        height: 44,
        child: Row(
          children: <Widget>[
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? Colors.orange,
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
}

class _AppVersion extends StatelessWidget {
  const _AppVersion({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.white,
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Version of application 1.0.0',
            textAlign: TextAlign.start,
          ),
        ),
      ),
    );
  }
}
