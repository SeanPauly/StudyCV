import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'socket_manager.dart';

// Defining a class for academic stats, projects, extracurriculars, and work experience might follow a similar pattern.
class AcademicStat {
  final String icon;
  final String title;
  final String value;

  AcademicStat({required this.icon, required this.title, required this.value});

  factory AcademicStat.fromJson(Map<String, dynamic> json) {
    return AcademicStat(
      icon: json['icon'],
      title: json['title'],
      value: json['value'],
    );
  }
}

// Defining a class for academic stats, projects, extracurriculars, and work experience might follow a similar pattern.
class VolunteerStat {
  final String icon;
  final String title;
  final String value;

  VolunteerStat({required this.icon, required this.title, required this.value});

  factory VolunteerStat.fromJson(Map<String, dynamic> json) {
    return VolunteerStat(
      icon: json['icon'],
      title: json['title'],
      value: json['hours'],
    );
  }
}

class WorkExperienceStat {
  final String icon;
  final String title;
  final String value;

  WorkExperienceStat({required this.icon, required this.title, required this.value});

  factory WorkExperienceStat.fromJson(Map<String, dynamic> json) {
    return WorkExperienceStat(
      icon: json['icon'],
      title: json['role'],
      value: json['duration'],
    );
  }
}

class ExtracurricularsStat {
  final String icon;
  final String title;
  final String value;

  ExtracurricularsStat({required this.icon, required this.title, required this.value});

  factory ExtracurricularsStat.fromJson(Map<String, dynamic> json) {
    return ExtracurricularsStat(
      icon: json['icon'],
      title: json['title'],
      value: json['years'],
    );
  }
}

class AchievementsStat {
  final String icon;
  final String title;
  final String value;

  AchievementsStat({required this.icon, required this.title, required this.value});

  factory AchievementsStat.fromJson(Map<String, dynamic> json) {
    return AchievementsStat(
      icon: json['icon'],
      title: json['title'],
      value: json['year'],
    );
  }
}

class ProjectsStat {
  final String icon;
  final String title;
  final String value;

  ProjectsStat({required this.icon, required this.title, required this.value});

  factory ProjectsStat.fromJson(Map<String, dynamic> json) {
    return ProjectsStat(
      icon: json['icon'],
      title: json['title'],
      value: json['year'],
    );
  }
}

class UserProfile {
  final String name;
  final String grade;
  final List<AcademicStat> academics;
  final List<VolunteerStat> volunteerism;
  final List<WorkExperienceStat> workexperience;
  final List<ExtracurricularsStat> extracurricular;
  final List<AchievementsStat> achievements;
  final List<ProjectsStat> projects;

  UserProfile({
    required this.name,
    required this.grade,
    required this.academics,
    required this.volunteerism,
    required this.workexperience,
    required this.extracurricular,
    required this.achievements,
    required this.projects,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    var academicsList = json['academics'] as List;
    var volunteerismList = json['volunteerism'] as List;
    var workexperienceList = json['workexperience'] as List;
    var extracurricularList = json['extracurriculars'] as List;
    var achievementsList = json['achievements'] as List;
    var projectsList = json['projects'] as List;

    return UserProfile(
      name: json['name'],
      grade: json['grade'],
      academics: academicsList.map((i) => AcademicStat.fromJson(i)).toList(),
      volunteerism: volunteerismList.map((i) => VolunteerStat.fromJson(i)).toList(),
      workexperience: workexperienceList.map((i) => WorkExperienceStat.fromJson(i)).toList(),
      extracurricular: extracurricularList.map((i) => ExtracurricularsStat.fromJson(i)).toList(),
      achievements: achievementsList.map((i) => AchievementsStat.fromJson(i)).toList(),
      projects: projectsList.map((i) => ProjectsStat.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'grade': grade,
      'academics': academics.map((i) => i.toJson()).toList(),
      'volunteerism': volunteerism.map((i) => i.toJson()).toList(),
      'workexperience': workexperience.map((i) => i.toJson()).toList(),
      'extracurricular': extracurricular.map((i) => i.toJson()).toList(),
      'achievements': achievements.map((i) => i.toJson()).toList(),
      'projects': projects.map((i) => i.toJson()).toList(),
    };
  }
}

class UserProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  void updateUserProfile(Map<String, dynamic> data) {
    _userProfile = UserProfile.fromJson(data);
    notifyListeners();
  }

  void saveUserProfileChanges(BuildContext context) {
    if (_userProfile != null) {
      final socketManager = Provider.of<SocketManager>(context, listen: false);
      socketManager.emit('update_profile', _userProfile!.toJson());
    }
  }

  void updateUserAcademicStat(int index, AcademicStat updatedStat) {}
}

extension on AcademicStat {
  Map<String, dynamic> toJson() => {
        'icon': icon,
        'title': title,
        'value': value,
      };
}

extension on VolunteerStat {
  Map<String, dynamic> toJson() => {
        'icon': icon,
        'title': title,
        'value': value,
      };
}

extension on WorkExperienceStat {
  Map<String, dynamic> toJson() => {
        'icon': icon,
        'title': title,
        'value': value,
      };
}

extension on ExtracurricularsStat {
  Map<String, dynamic> toJson() => {
        'icon': icon,
        'title': title,
        'value': value,
      };
}

extension on AchievementsStat {
  Map<String, dynamic> toJson() => {
        'icon': icon,
        'title': title,
        'value': value,
      };
}

extension on ProjectsStat {
  Map<String, dynamic> toJson() => {
        'icon': icon,
        'title': title,
        'value': value,
      };
}

