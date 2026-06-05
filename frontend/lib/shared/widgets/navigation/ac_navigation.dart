// file: lib/shared/widgets/navigation/ac_navigation.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/themes/app_gradients.dart';
import '../../../core/themes/app_shadows.dart';

// ─── NavItem model ────────────────────────────────────────────────────────
class AcNavItem {
  const AcNavItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
    this.route,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String? badge;
  final String? route;
}

// ─── AcSidebar ────────────────────────────────────────────────────────────
class AcSidebar extends StatefulWidget {
  const AcSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.header,
    this.footer,
    this.isCollapsed = false,
    this.onToggleCollapsed,
    this.userAvatarUrl,
    this.userName,
    this.userRole,
  });

  final List<AcNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Widget? header;
  final Widget? footer;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapsed;
  final String? userAvatarUrl;
  final String? userName;
  final String? userRole;

  @override
  State<AcSidebar> createState() => _AcSidebarState();
}

class _AcSidebarState extends State<AcSidebar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _collapseCtrl;
  late final Animation<double> _width;

  @override
  void initState() {
    super.initState();
    _collapseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.isCollapsed ? 1.0 : 0.0,
    );
    _width = Tween<double>(
      begin: AppSpacing.navRailWidth,
      end: AppSpacing.navRailWidthCollapsed,
    ).animate(CurvedAnimation(parent: _collapseCtrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(AcSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _collapseCtrl.forward();
      } else {
        _collapseCtrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _collapseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _width,
      builder: (context, child) => Container(
        width: _width.value,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.sidebarBackground,
          border: Border(
            left: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: AppShadows.panel,
        ),
        child: Column(
          children: [
            // ── Logo / Brand ──────────────────────────────────────
            Container(
              height: AppSpacing.topBarHeight,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isCollapsed ? AppSpacing.md : AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.primaryDiagonal,
                      borderRadius: AppRadius.brSm,
                      boxShadow: AppShadows.primaryGlow,
                    ),
                    child: const Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: AppColors.neutral0,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  if (!widget.isCollapsed) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Text('Acadexa', style: AppTypography.h4),
                  ],
                  if (!widget.isCollapsed) const Spacer(),
                  if (widget.onToggleCollapsed != null && !widget.isCollapsed)
                    IconButton(
                      onPressed: widget.onToggleCollapsed,
                      icon: const Icon(
                        Icons.menu_open_rounded,
                        color: AppColors.textSecondary,
                      ),
                      iconSize: 20,
                    ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Nav items ─────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.sm,
                ),
                child: ListView.separated(
                  itemCount: widget.items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.xxs),
                  itemBuilder: (_, i) => _NavTile(
                    item: widget.items[i],
                    isSelected: widget.selectedIndex == i,
                    isCollapsed: widget.isCollapsed,
                    onTap: () => widget.onItemSelected(i),
                  ),
                ),
              ),
            ),

            // ── User profile strip ────────────────────────────────
            if (widget.userName != null) ...[
              const Divider(height: 1),
              _UserStrip(
                avatarUrl: widget.userAvatarUrl,
                name: widget.userName!,
                role: widget.userRole,
                isCollapsed: widget.isCollapsed,
              ),
            ],

            // ── Footer ────────────────────────────────────────────
            if (widget.footer != null) widget.footer!,
          ],
        ),
      ),
    );
  }
}

// ─── _NavTile ─────────────────────────────────────────────────────────────
class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  final AcNavItem item;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final icon = widget.isSelected
        ? (widget.item.selectedIcon ?? widget.item.icon)
        : widget.item.icon;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        selected: widget.isSelected,
        button: true,
        label: widget.item.label,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 44,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.primary50
                  : _hovered
                  ? AppColors.neutral100
                  : Colors.transparent,
              borderRadius: AppRadius.brSm,
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.sm),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: widget.isSelected
                          ? AppColors.primary500
                          : AppColors.textSecondary,
                    ),
                    if (widget.item.badge != null)
                      Positioned(
                        top: -4,
                        left: -4,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 16),
                          height: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.danger500,
                            borderRadius: AppRadius.brPill,
                          ),
                          child: Text(
                            widget.item.badge!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.neutral0,
                              fontSize: 9,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.item.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: widget.isSelected
                          ? AppColors.primary500
                          : AppColors.textSecondary,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  if (widget.isSelected)
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Container(
                          width: 3,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primary500,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(3),
                              bottomLeft: Radius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── _UserStrip ───────────────────────────────────────────────────────────
class _UserStrip extends StatelessWidget {
  const _UserStrip({
    required this.name,
    this.avatarUrl,
    this.role,
    required this.isCollapsed,
  });

  final String name;
  final String? avatarUrl;
  final String? role;
  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
            backgroundColor: AppColors.primary100,
            child: avatarUrl == null
                ? Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary700,
                    ),
                  )
                : null,
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (role != null)
                    Text(
                      role!,
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.more_vert_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── AcTopBar ─────────────────────────────────────────────────────────────
class AcTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AcTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
    AppSpacing.topBarHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTypography.h4),
          if (subtitle != null) Text(subtitle!, style: AppTypography.caption),
        ],
      ),
      actions: [
        if (actions != null) ...actions!,
        const SizedBox(width: AppSpacing.sm),
      ],
      bottom: bottom,
    );
  }
}

// ─── AcBottomNav ──────────────────────────────────────────────────────────
class AcBottomNav extends StatelessWidget {
  const AcBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final List<AcNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemSelected,
        destinations: items
            .map(
              (e) => NavigationDestination(
                icon: Icon(e.icon),
                selectedIcon: Icon(e.selectedIcon ?? e.icon),
                label: e.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── AcAdaptiveLayout ─────────────────────────────────────────────────────
/// Automatically switches between sidebar (desktop) and bottom nav (mobile)
class AcAdaptiveLayout extends StatelessWidget {
  const AcAdaptiveLayout({
    super.key,
    required this.navItems,
    required this.selectedIndex,
    required this.onNavItemSelected,
    required this.body,
    this.sidebarIsCollapsed = false,
    this.onToggleSidebar,
    this.topBar,
    this.fab,
    this.userAvatarUrl,
    this.userName,
    this.userRole,
  });

  final List<AcNavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onNavItemSelected;
  final Widget body;
  final bool sidebarIsCollapsed;
  final VoidCallback? onToggleSidebar;
  final PreferredSizeWidget? topBar;
  final Widget? fab;
  final String? userAvatarUrl;
  final String? userName;
  final String? userRole;

  static const double _tabletBreakpoint = 768;
  static const double _desktopBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= _tabletBreakpoint;
        final isDesktop = constraints.maxWidth >= _desktopBreakpoint;

        if (isTablet) {
          // ── Sidebar layout ────────────────────────────────────
          return Scaffold(
            appBar: topBar,
            floatingActionButton: fab,
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  AcSidebar(
                    items: navItems,
                    selectedIndex: selectedIndex,
                    onItemSelected: onNavItemSelected,
                    isCollapsed: !isDesktop || sidebarIsCollapsed,
                    onToggleCollapsed: onToggleSidebar,
                    userAvatarUrl: userAvatarUrl,
                    userName: userName,
                    userRole: userRole,
                  ),
                  Expanded(child: body),
                ],
              ),
            ),
          );
        }

        // ── Bottom nav layout ────────────────────────────────────
        return Scaffold(
          appBar: topBar,
          body: body,
          bottomNavigationBar: AcBottomNav(
            items: navItems,
            selectedIndex: selectedIndex,
            onItemSelected: onNavItemSelected,
          ),
          floatingActionButton: fab,
        );
      },
    );
  }
}
