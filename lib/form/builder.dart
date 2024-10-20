import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl_components/card.dart';
import 'package:intl_components/form/form.dart' as components;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class DynamicFormBuilder extends StatefulWidget {
  final components.Form form;
  final void Function(Map<String, dynamic>) onSubmit;

  const DynamicFormBuilder({
    required this.form,
    required this.onSubmit,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DynamicFormBuilderState createState() => _DynamicFormBuilderState();
}

class _DynamicFormBuilderState extends State<DynamicFormBuilder> {
  late FormSchema _formSchema;
  final _formKey = GlobalKey<FormBuilderState>();
  // ignore: prefer_final_fields
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    _loadFormSchema();
  }

  Future<void> _loadFormSchema() async {
    final jsonString = await widget.form.jsonInput();
    final jsonMap = jsonDecode(jsonString);
    setState(() {
      _formSchema = FormSchema.fromJson(jsonMap);
    });
  }

  @override
  Widget build(BuildContext context) => CardWithTitle(
        title: _formSchema.title,
        // ignore: unnecessary_null_comparison
        body: _formSchema != null
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ..._formSchema.fields
                          .map((field) => _buildFormField(field))
                          .toList(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.saveAndValidate()) {
                            widget.onSubmit(_formData);
                          }
                        },
                        child: Text(_formSchema.submitButtonText),
                      ),
                    ],
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      );

  Widget _buildFormField(components.Field field) {
    switch (field.type) {
      case components.FieldType.text:
      case components.FieldType.password:
      case components.FieldType.email:
        return FormBuilderTextField(
          name: field.name,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
          ),
          obscureText: field.type == components.FieldType.password,
          validator: FormBuilderValidators.compose([
            if (field.required == true) FormBuilderValidators.required(),
            if (field.minLength != null)
              FormBuilderValidators.minLength(field.minLength!),
            if (field.maxLength != null)
              FormBuilderValidators.maxLength(field.maxLength!),
            // if (field.pattern != null)
            //   FormBuilderValidators.pattern(field.pattern!,
            //       errorText: field.patternError),
          ]),
          onSaved: (value) => _formData[field.name] = value,
        );
      case components.FieldType.select:
        return FormBuilderDropdown(
          name: field.name,
          decoration: InputDecoration(
              labelText: field.label, hintText: field.placeholder),
          items: field.options!
              .map((option) => DropdownMenuItem(
                    value: option.value,
                    child: Text(option.label),
                  ))
              .toList(),
        );
      case components.FieldType.checkbox:
        return FormBuilderCheckbox(
          name: field.name,
          title: Text(field.label),
        );
      case components.FieldType.textarea:
        return FormBuilderTextField(
          name: field.name,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
          ),
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          validator: FormBuilderValidators.compose([
            if (field.required == true) FormBuilderValidators.required(),
            if (field.maxLength != null)
              FormBuilderValidators.maxLength(field.maxLength!),
          ]),
          onSaved: (value) => _formData[field.name] = value,
        );
      case components.FieldType.date:
        return FormBuilderDateTimePicker(
          name: field.name,
          decoration: InputDecoration(
              labelText: field.label, hintText: field.placeholder),
          inputType: InputType.date,
        );
      case components.FieldType.number:
        return FormBuilderTextField(
          name: field.name,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
          ),
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.compose([
            if (field.required == true) FormBuilderValidators.required(),
            if (field.min != null) FormBuilderValidators.min(field.min!),
            if (field.max != null) FormBuilderValidators.max(field.max!),
          ]),
          onSaved: (value) => _formData[field.name] = int.parse(value!),
        );
      case components.FieldType.numberRange:
        return FormBuilderRangeSlider(
          name: field.name,
          decoration: InputDecoration(
              labelText: field.label, hintText: field.placeholder),
          min: field.min!.toDouble(),
          max: field.max!.toDouble(),
          initialValue: const RangeValues(0, 100),
          divisions: (field.max! - field.min!).toInt(),
        );
      case components.FieldType.dateRange:
        return FormBuilderRangeSlider(
          name: field.name,
          decoration: InputDecoration(labelText: field.label),
          min: field.min!.toDouble(),
          max: field.max!.toDouble(),
          initialValue: RangeValues(
              DateTime.now()
                  .subtract(const Duration(days: 365))
                  .millisecondsSinceEpoch
                  .toDouble(),
              DateTime.now().millisecondsSinceEpoch.toDouble()),
          divisions: (field.max! - field.min!).toInt(),
          // format: (value) => DateTime.fromMillisecondsSinceEpoch(value.toInt())
          //     .toString()
          //     .split(' ')[0],
        );
      case components.FieldType.radio:
        return FormBuilderRadioGroup(
          name: field.name,
          decoration: InputDecoration(labelText: field.label),
          options: field.options!
              .map((option) => FormBuilderFieldOption(
                    value: option.value,
                    child: Text(option.label),
                  ))
              .toList(),
        );
      case components.FieldType.range:
        return FormBuilderSlider(
          initialValue: 0,
          name: field.name,
          decoration: InputDecoration(labelText: field.label),
          min: field.min!.toDouble(),
          max: field.max!.toDouble(),
          divisions: (field.max! - field.min!).toInt(),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// Class representing the overall form schema
class FormSchema {
  String title; // Title of the form
  String submitButtonText; // Text for the submit button
  List<components.Field> fields; // List of fields in the form

  FormSchema({
    required this.title,
    required this.submitButtonText,
    required this.fields,
  });

  factory FormSchema.fromJson(Map<String, dynamic> json) => FormSchema(
        title: json['title'] ?? '',
        submitButtonText: json['submitButtonText'] ?? 'Submit',
        fields: List<components.Field>.from(
          (json['fields'] as List)
              .map((field) => components.Field.fromJson(field)),
        ),
      );
}
