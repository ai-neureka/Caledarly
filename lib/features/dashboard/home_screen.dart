import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/schedules/controller/schedules_controller.dart';
import 'package:apc_schedular/features/schedules/model/all_activitie.dart';
import 'package:apc_schedular/features/schedules/presentation/schedule_detail_screen.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _newsPageController = PageController();
  List<NewsArticle> newsArticles = [];
  bool loadingNews = true;
  final _schedulesController = Get.put(SchedulesController());
  @override
  void initState() {
    super.initState();

    _schedulesController.getAllUserActivitiesController();

    _fetchNigerianNews();
  }

  @override
  void dispose() {
    _newsPageController.dispose();
    super.dispose();
  }

  Future<void> _fetchNigerianNews() async {
    try {
      // Get your free API key from https://newsapi.org/register
      const apiKey = '609730647a374a8bb2c9e816dc7621f7';

      final response = await http.get(
        Uri.parse(
          'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          newsArticles = (data['articles'] as List)
              .take(10)
              .map((article) => NewsArticle.fromJson(article))
              .toList();
          loadingNews = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() => loadingNews = false);
      }
    } catch (e) {
      setState(() => loadingNews = false);
      print('Error fetching news: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(children: [_buildTabButton("Today", 0)]),
            ),
            Expanded(child: _buildTodayPage(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.bottomCenter,
          //   end: Alignment.topRight,
          //   tileMode: TileMode.mirror,
          //   colors: [AppColors.blackColor, Color(0xFFFFFFFF)],
          // ),
          borderRadius: BorderRadius.circular(60),
          color: AppColors.blackColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Text(
          text,
          style: AppTextStyle().textInter(
            size: 14.0,
            weight: FontWeight.w400,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTodayPage(BuildContext context) {
    final now = DateTime.now();
    final currentDay = DateFormat('EEEE').format(now);
    final currentDate = DateFormat('dd.MM').format(now);
    final currentMonth = DateFormat('MMM').format(now);
    final currentTime = DateFormat('hh:mma').format(now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   currentDay,
          //   style: AppTextStyle().textInter(
          //     size: 16.0,
          //     weight: FontWeight.w600,
          //     color: AppColors.blackColor,
          //   ),
          // ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentDate,
                    style: AppTextStyle().textInter(
                      size: 60.0,
                      weight: FontWeight.w900,
                      color: AppColors.blackColor,
                    ),
                  ),
                  Text(
                    currentMonth,
                    style: AppTextStyle().textInter(
                      size: 60.0,
                      weight: FontWeight.w900,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: 1,
                color: AppColors.blackColor,
              ),
              Column(
                children: [
                  Text(
                    currentTime,
                    style: AppTextStyle().textInter(
                      size: 16.0,
                      weight: FontWeight.w500,
                      color: AppColors.blackColor,
                    ),
                  ),
                  Text(
                    'Nigeria',
                    style: AppTextStyle().textInter(
                      size: 16.0,
                      weight: FontWeight.w500,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Tasks Section
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.whiteColor.withValues(alpha: 0.6),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's tasks",
                    style: AppTextStyle().textInter(
                      size: 16.0,
                      weight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GetX<SchedulesController>(
                    builder: (controller) {
                      if (controller.loadingAllActivities.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.blackColor,
                          ),
                        );
                      }
                      if (controller.loadedActivities.value.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No tasks for today',
                            style: AppTextStyle().textInter(
                              size: 16.0,
                              weight: FontWeight.w600,
                              color: AppColors.blackColor,
                            ),
                          ),
                        );
                      }
                      final todayTasks = _getTodayTasks(
                        controller.loadedActivities.value.data ?? [],
                      );

                      if (todayTasks.isEmpty) {
                        return Center(
                          child: Text(
                            'No tasks for today',
                            style: AppTextStyle().textInter(
                              size: 16.0,
                              weight: FontWeight.w600,
                              color: AppColors.blackColor,
                            ),
                          ),
                        );
                      }

                      todayTasks.sort((a, b) {
                        final dateA =
                            a.createdAt ??
                            DateTime.fromMillisecondsSinceEpoch(0);
                        final dateB =
                            b.createdAt ??
                            DateTime.fromMillisecondsSinceEpoch(0);
                        return dateB.compareTo(dateA);
                      });

                      final task = todayTasks.first;

                      return GestureDetector(
                        onTap: () {
                          Get.to(
                            () => ScheduleDetailScreen(
                              id: task.id ?? '',
                              title: task.title ?? '',
                            ),
                          );
                        },
                        child: _buildTaskItem(task),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // News Section
          Text(
            "News",
            style: AppTextStyle().textInter(
              size: 16.0,
              weight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: AppColors.whiteColor.withValues(alpha: 0.6),
            ),
            child: loadingNews
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.whiteColor,
                    ),
                  )
                : newsArticles.isEmpty
                ? Center(
                    child: Text(
                      'No news available',
                      style: AppTextStyle().textInter(
                        size: 14.0,
                        weight: FontWeight.w500,
                        color: AppColors.blackColor,
                      ),
                    ),
                  )
                : _buildNewsCarousel(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<ScheduleDatum> _getTodayTasks(List<ScheduleDatum> allTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return allTasks.where((task) {
      if (task.createdAt == null) return false;
      final taskDate = DateTime(
        task.createdAt!.year,
        task.createdAt!.month,
        task.createdAt!.day,
      );
      return taskDate.isAtSameMomentAs(today);
    }).toList();
  }

  Widget _buildTaskItem(ScheduleDatum task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title ?? '',
                  style: AppTextStyle().textInter(
                    size: 22.0,
                    weight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priorityLevel),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.priorityLevel ?? '',
                  style: AppTextStyle().textInter(
                    size: 16.0,
                    weight: FontWeight.w500,
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
            ],
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              task.description!,
              style: AppTextStyle().textInter(
                size: 12.0,
                weight: FontWeight.w400,
                color: AppColors.blackColor.withValues(alpha: 0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.category, size: 20, color: AppColors.blue),
              const SizedBox(width: 4),
              Text(
                task.categoryId?.name ?? 'No category',
                style: AppTextStyle().textInter(
                  size: 20.0,
                  weight: FontWeight.w800,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 12),
              // Icon(Icons.access_time, size: 20, color: AppColors.blackColor),
              // const SizedBox(width: 4),
              // Text(
              //   '${task.duration ?? 0} min',
              //   style: AppTextStyle().textInter(
              //     size: 20,
              //     weight: FontWeight.w800,
              //     color: AppColors.blackColor,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return AppColors.blue;
    }
  }

  Widget _buildNewsCarousel() {
    return PageView.builder(
      onPageChanged: (index) {
        Future.delayed(const Duration(seconds: 4), () {
          if (!_newsPageController.hasClients || newsArticles.isEmpty) return;
          final next = (index + 1) % newsArticles.length;
          _newsPageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        });
      },
      controller: _newsPageController,
      scrollDirection: Axis.horizontal,
      itemCount: newsArticles.length,

      itemBuilder: (context, index) {
        final article = newsArticles[index];
        return GestureDetector(
          onTap: () => _openNewsArticle(article.url),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.whiteColor,
              ),
              child: Stack(
                children: [
                  if (article.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        article.imageUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.blue.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: AppColors.blue,
                            ),
                          );
                        },
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: AppTextStyle().textInter(
                              size: 14.0,
                              weight: FontWeight.w600,
                              color: AppColors.whiteColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            article.source,
                            style: AppTextStyle().textInter(
                              size: 11.0,
                              weight: FontWeight.w400,
                              color: AppColors.whiteColor.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openNewsArticle(String? url) async {
    if (url != null) {
      await launchUrl(Uri.parse(url));
      print('Opening: $url');
    }
  }
}

class NewsArticle {
  final String title;
  final String source;
  final String? imageUrl;
  final String? url;

  NewsArticle({
    required this.title,
    required this.source,
    this.imageUrl,
    this.url,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No title',
      source: json['source']?['name'] ?? 'Unknown source',
      imageUrl: json['urlToImage'],
      url: json['url'],
    );
  }
}
