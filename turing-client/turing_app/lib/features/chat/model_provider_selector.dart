import 'package:flutter/material.dart';

class ModelProviderSelector extends StatelessWidget {
  const ModelProviderSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      items: const [
        DropdownMenuItem(value: 'ollama', child: Text('Ollama')),
        DropdownMenuItem(
          value: 'openai_compatible',
          child: Text('OpenAI-compatible'),
        ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
