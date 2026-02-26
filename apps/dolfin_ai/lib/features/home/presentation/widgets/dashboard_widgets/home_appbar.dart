import 'package:dolfin_ui_kit/theme/theme_cubit.dart';
import 'package:dolfin_ui_kit/theme/theme_state.dart';
import 'package:balance_iq/features/home/domain/entities/dashbaord_summary.dart';
import 'package:balance_iq/core/icons/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class HomeAppbar extends StatelessWidget {
  final VoidCallback onTapProfileIcon;
  final String profileUrl;
  final String displayDate;
  final GlobalKey? profileIconKey;
  final String userName;

  const HomeAppbar({
    super.key,
    required this.summary,
    required this.onTapProfileIcon,
    required this.profileUrl,
    required this.displayDate,
    this.onTapDateRange,
    this.profileIconKey,
    this.userName = '',
  });

  final DashboardSummary summary;
  final VoidCallback? onTapDateRange;

  String _getInitial() {
    if (userName.isNotEmpty) {
      return userName[0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverAppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      centerTitle: true,
      title: InkWell(
        onTap: onTapDateRange,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayDate,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 4),
              GetIt.I<AppIcons>().navigation.chevronDown(
                    size: 20,
                    color: textTheme.titleMedium?.color,
                  ),
            ],
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          key: profileIconKey,
          onTap: onTapProfileIcon,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary,
            ),
            padding: const EdgeInsets.all(3),
            child: profileUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: NetworkImage(profileUrl),
                    onBackgroundImageError: (_, __) {},
                  )
                : CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      _getInitial(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ),
      ),
      actions: [
        BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return InkWell(
              onTap: () {
                context.read<ThemeCubit>().toggleTheme();
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: isDark
                    ? GetIt.I<AppIcons>().dashboard.lightMode(
                          size: 20,
                          color: colorScheme.primary,
                        )
                    : GetIt.I<AppIcons>().dashboard.darkMode(
                          size: 20,
                          color: colorScheme.primary,
                        ),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}
