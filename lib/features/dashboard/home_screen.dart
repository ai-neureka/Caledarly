import 'dart:convert';

import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/schedules/controller/schedules_controller.dart';
import 'package:apc_schedular/features/schedules/model/all_activity_instances_model.dart';
import 'package:apc_schedular/features/schedules/presentation/schedule_detail_screen.dart';
import 'package:apc_schedular/features/widget/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _newsController = PageController();
  final _schedules = Get.put(SchedulesController());
  List<NewsArticle> _articles = [];
  bool _loadingNews = true;

  @override
  void initState() {
    super.initState();
    _schedules.getAllUserActivitiesController();
    _fetchNews();
  }

  @override
  void dispose() {
    _newsController.dispose();
    super.dispose();
  }

  Future<void> _fetchNews() async {
    try {
      const key = '609730647a374a8bb2c9e816dc7621f7';
      final response = await http.get(
        Uri.parse(
          'https://newsapi.org/v2/top-headlines?country=us&apiKey=$key',
        ),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _articles = (data['articles'] as List<dynamic>)
            .take(10)
            .map((item) => NewsArticle.fromJson(item))
            .toList();
      }
    } catch (_) {
      // A quiet empty state keeps the dashboard useful while offline.
    }
    if (mounted) setState(() => _loadingNews = false);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(now),
              const SizedBox(height: 24),
              _overview(now),
              const SizedBox(height: 28),
              _sectionTitle("Today's schedule", 'View all'),
              const SizedBox(height: 14),
              _activities(now),
              const SizedBox(height: 28),
              _sectionTitle('Headlines', 'Latest updates'),
              const SizedBox(height: 14),
              _news(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(DateTime now) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(now),
              style: _text(14, FontWeight.w600, AppColors.secondaryText),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, d MMMM').format(now),
              style: _text(24, FontWeight.w700, AppColors.primaryText),
            ),
          ],
        ),
      ),
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.notifications_none_rounded,
          color: AppColors.primaryText,
        ),
      ),
    ],
  );

  Widget _overview(DateTime now) => Obx(() {
    if (_schedules.loadingAllActivities.value) {
      return AppShimmer(
        baseColor: AppColors.primary.withValues(alpha: .82),
        child: const ShimmerBox(
          height: 154,
          borderRadius: 8,
          color: AppColors.primary,
        ),
      );
    }
    final activities = _today(
      _schedules.loadedActivities.value.data ?? [],
      now,
    );
    final completed = activities
        .where((item) => item.startTime!.isBefore(now))
        .length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY AT A GLANCE',
            style: _text(
              11,
              FontWeight.w700,
              AppColors.whiteColor.withValues(alpha: .72),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${activities.length} ${activities.length == 1 ? 'activity' : 'activities'} planned',
            style: _text(23, FontWeight.w700, AppColors.whiteColor),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _metric('$completed', 'completed'),
              Container(height: 28, width: 1, color: Colors.white24),
              const SizedBox(width: 18),
              _metric('${activities.length - completed}', 'remaining'),
            ],
          ),
        ],
      ),
    );
  });

  Widget _metric(String value, String label) => Padding(
    padding: const EdgeInsets.only(right: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: _text(18, FontWeight.w700, AppColors.whiteColor)),
        Text(
          label,
          style: _text(
            12,
            FontWeight.w400,
            AppColors.whiteColor.withValues(alpha: .68),
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String title, String action) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: _text(18, FontWeight.w700, AppColors.primaryText),
        ),
      ),
      Text(action, style: _text(12, FontWeight.w600, AppColors.secondary)),
    ],
  );

  Widget _activities(DateTime now) => GetX<SchedulesController>(
    builder: (controller) {
      if (controller.loadingAllActivities.value)
        return const _ActivitiesShimmer();
      final activities = _today(
        controller.loadedActivities.value.data ?? [],
        now,
      )..sort((a, b) => a.startTime!.compareTo(b.startTime!));
      if (activities.isEmpty)
        return _empty(
          'No activities scheduled for today.',
          Icons.event_available_outlined,
        );
      return SizedBox(
        height: 164,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: activities.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, index) => _activityCard(activities[index], now),
        ),
      );
    },
  );

  Widget _activityCard(ScheduleDatum item, DateTime now) {
    final past = item.startTime!.isBefore(now);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Get.to(
        () => ScheduleDetailScreen(
          id: item.id ?? '',
          title: item.activityId?.title ?? '',
        ),
      ),
      child: Container(
        width: 244,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _priority(item.activityId?.priorityLevel),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('h:mm a').format(item.startTime!),
                  style: _text(
                    12,
                    FontWeight.w600,
                    past ? AppColors.secondaryText : AppColors.secondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              item.activityId?.title ?? 'Untitled activity',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _text(
                16,
                FontWeight.w700,
                past ? AppColors.secondaryText : AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.activityId?.description?.isNotEmpty == true
                  ? item.activityId!.description!
                  : item.activityId?.priorityLevel ?? 'Scheduled',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _text(12, FontWeight.w400, AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _news() {
    if (_loadingNews)
      return const AppShimmer(child: ShimmerBox(height: 184, borderRadius: 8));
    if (_articles.isEmpty)
      return _empty(
        'No headlines available right now.',
        Icons.newspaper_outlined,
      );
    return SizedBox(
      height: 184,
      child: PageView.builder(
        controller: _newsController,
        itemCount: _articles.length,
        itemBuilder: (_, index) => _newsCard(_articles[index]),
      ),
    );
  }

  Widget _newsCard(NewsArticle item) => InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: () => _openArticle(item.url),
    child: Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 128,
            height: double.infinity,
            child: item.imageUrl == null
                ? _newsFallback()
                : Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _newsFallback(),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.source.toUpperCase(),
                    style: _text(10, FontWeight.w700, AppColors.secondary),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: _text(15, FontWeight.w700, AppColors.primaryText),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _newsFallback() => Container(
    color: AppColors.mutedSurface,
    child: const Icon(
      Icons.newspaper_outlined,
      size: 36,
      color: AppColors.secondary,
    ),
  );
  Widget _empty(String message, IconData icon) => Container(
    height: 126,
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.mutedSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.secondary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            message,
            style: _text(14, FontWeight.w600, AppColors.primaryText),
          ),
        ),
      ],
    ),
  );
  List<ScheduleDatum> _today(List<ScheduleDatum> items, DateTime date) => items
      .where(
        (item) =>
            item.startTime != null && DateUtils.isSameDay(item.startTime, date),
      )
      .toList();
  String _greeting(DateTime now) => now.hour < 12
      ? 'Good morning'
      : now.hour < 17
      ? 'Good afternoon'
      : 'Good evening';
  Color _priority(String? value) => switch (value?.toLowerCase()) {
    'high' => AppColors.error,
    'medium' => AppColors.accent,
    'low' => AppColors.success,
    _ => AppColors.secondary,
  };
  TextStyle _text(double size, FontWeight weight, Color color) =>
      AppTextStyle().textInter(size: size, weight: weight, color: color);
  Future<void> _openArticle(String? url) async {
    if (url != null)
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

class _ActivitiesShimmer extends StatelessWidget {
  const _ActivitiesShimmer();
  @override
  Widget build(BuildContext context) => AppShimmer(
    child: SizedBox(
      height: 164,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) =>
            const ShimmerBox(height: 164, width: 244, borderRadius: 8),
      ),
    ),
  );
}

class NewsArticle {
  const NewsArticle({
    required this.title,
    required this.source,
    this.imageUrl,
    this.url,
  });
  final String title;
  final String source;
  final String? imageUrl;
  final String? url;
  factory NewsArticle.fromJson(Map<String, dynamic> json) => NewsArticle(
    title: json['title'] as String? ?? 'No title',
    source:
        (json['source'] as Map<String, dynamic>?)?['name'] as String? ??
        'Unknown source',
    imageUrl: json['urlToImage'] as String?,
    url: json['url'] as String?,
  );
}
