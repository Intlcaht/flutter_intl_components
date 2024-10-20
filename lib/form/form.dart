import 'dart:async';

// Enum to represent different types of form fields
enum FieldType {
  text, // Text input field
  password, // Password input field
  email, // Email input field
  select, // Dropdown/select input field
  checkbox, // Checkbox input field
  textarea, // Textarea input field
  date, // Date input field
  number, // Number input field
  numberRange, // Number range input field
  dateRange, // Date range input field
  radio, // Radio button input field
  range, // Range input field
}

// Class representing an individual form field
class Field {
  FieldType type; // Type of the field
  String name; // Name of the field
  String label; // Label for the field
  String? placeholder; // Placeholder text for the field (optional)
  bool? required; // Indicates if the field is required (optional)
  List<Option>?
      options; // List of options for select or radio fields (optional)
  int? min; // Minimum value for number or range fields (optional)
  int? max; // Maximum value for number or range fields (optional)
  int? step; // Step value for number fields (optional)
  int? minLength; // Minimum length for text fields (optional)
  int? maxLength; // Maximum length for text fields (optional)
  String? pattern; // Regex pattern for validating text fields (optional)
  String? patternError; // Error message for pattern validation (optional)

  Field({
    required this.type,
    required this.name,
    required this.label,
    this.placeholder,
    this.required,
    this.options,
    this.min,
    this.max,
    this.step,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.patternError,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      type: FieldType.values.firstWhere(
        (type) => type.toString() == 'FieldType.${json['type']}',
        orElse: () => FieldType.text,
      ),
      name: json['name'] ?? '',
      label: json['label'] ?? '',
      placeholder: json['placeholder'],
      required: json['required'],
      options: json['options'] != null
          ? List<Option>.from(
              (json['options'] as List)
                  .map((option) => Option.fromJson(option)),
            )
          : null,
      min: json['min'],
      max: json['max'],
      step: json['step'],
      minLength: json['minLength'],
      maxLength: json['maxLength'],
      pattern: json['pattern'],
      patternError: json['patternError'],
    );
  }
}

// Class representing an option for select or radio fields
class Option {
  String label; // Label for the option
  String value; // Value for the option

  Option({
    required this.label,
    required this.value,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      label: json['label'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

// Abstract class representing a form with a method to get its schema in JSON format
abstract class Form {
  // Asynchronous method to get the schema of the form in JSON format
  Future<String> jsonInput();
}
