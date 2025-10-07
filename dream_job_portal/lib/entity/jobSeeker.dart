import 'package:code/entity/education.dart';
import 'package:code/entity/experience.dart';
import 'package:code/entity/extracurricular.dart';
import 'package:code/entity/hobby.dart';
import 'package:code/entity/language.dart';
import 'package:code/entity/reference.dart';
import 'package:code/entity/skill.dart';
import 'package:code/entity/summary.dart';
import 'package:code/entity/training.dart';
import 'package:code/entity/user.dart';


class JobSeeker {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String address;
  final String dateOfBirth;
  final String photo;
  final User user;
  final List<Education> educations;
  final List<Reference> references;
  final List<Experience> experiences;
  final List<Hobby> hobbies;
  final List<Extracurricular> extracurriculars;
  final List<Language> languages;
  final List<Skill> skills;
  final List<Training> trainings;
  final List<Summary> summary;

  JobSeeker({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.address,
    required this.dateOfBirth,
    required this.photo,
    required this.user,
    required this.educations,
    required this.references,
    required this.experiences,
    required this.hobbies,
    required this.extracurriculars,
    required this.languages,
    required this.skills,
    required this.trainings,
    required this.summary,
  });

  factory JobSeeker.fromJson(Map<String, dynamic> json) {
    return JobSeeker(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      photo: json['photo'] ?? '',
      user: User.fromJson(json['user']),
      educations: (json['educations'] as List?)?.map((e) => Education.fromJson(e)).toList() ?? [],
      references: (json['refferences'] as List?)?.map((e) => Reference.fromJson(e)).toList() ?? [],
      experiences: (json['experiences'] as List?)?.map((e) => Experience.fromJson(e)).toList() ?? [],
      hobbies: (json['hobbies'] as List?)?.map((e) => Hobby.fromJson(e)).toList() ?? [],
      extracurriculars: (json['extracurriculars'] as List?)?.map((e) => Extracurricular.fromJson(e)).toList() ?? [],
      languages: (json['languages'] as List?)?.map((e) => Language.fromJson(e)).toList() ?? [],
      skills: (json['skills'] as List?)?.map((e) => Skill.fromJson(e)).toList() ?? [],
      trainings: (json['trainings'] as List?)?.map((e) => Training.fromJson(e)).toList() ?? [],
      summary: (json['summery'] as List?)?.map((e) => Summary.fromJson(e)).toList() ?? [],
    );
  }
}