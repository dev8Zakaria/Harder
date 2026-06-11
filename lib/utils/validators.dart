class Validators {
  static String? requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email obligatoire';
    }
    if (!value.contains('@')) {
      return 'Email invalide';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 4) {
      return 'Minimum 4 caractères';
    }
    return null;
  }

  static String? positiveNumber(String? value) {
    final number = double.tryParse(value ?? '');
    if (number == null || number <= 0) {
      return 'Valeur positive obligatoire';
    }
    return null;
  }
}
