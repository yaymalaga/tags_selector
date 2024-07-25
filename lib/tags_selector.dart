library tags_selector;

import 'package:flutter/material.dart';

class TagsSelector extends StatefulWidget {
  final Set<(String, Color)> tags;
  final void Function(String tag) onTagCreated;
  final void Function(String tag)? onTagUnselected;
  final void Function(String tag)? onTagSelected;

  const TagsSelector({
    super.key,
    required this.tags,
    required this.onTagCreated,
    this.onTagUnselected,
    this.onTagSelected,
  });

  @override
  State<TagsSelector> createState() => _TagsSelectorState();
}

class _TagsSelectorState extends State<TagsSelector> {
  final Set<(String, Color)> _selectedTags = {};

  String filter = "";

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTags = widget.tags.where((item) => item.$1.contains(filter));

    return Container(
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 48),
            width: double.infinity,
            color: Colors.grey.shade300,
            padding: const EdgeInsets.all(8),
            child: _selectedTags.isNotEmpty
                ? Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final tag in _selectedTags) ...[
                        Chip(
                          deleteIcon: const Icon(
                            Icons.close,
                          ),
                          onDeleted: () => setState(() {
                            _selectedTags.remove(tag);

                            if (widget.onTagUnselected != null) {
                              widget.onTagUnselected!(tag.$1);
                            }
                          }),
                          label: Text(tag.$1),
                          backgroundColor: tag.$2,
                        ),
                      ],
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 1),
                        child: IntrinsicWidth(
                          child: TextField(
                            decoration: const InputDecoration.collapsed(
                              hintText: null,
                            ),
                            onChanged: (value) => setState(() {
                              filter = value;
                            }),
                            autofocus: true,
                            focusNode: _focusNode,
                            controller: _textController,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: TextField(
                      decoration: const InputDecoration.collapsed(
                        hintText: "Search for an option...",
                      ),
                      onChanged: (value) => setState(() {
                        filter = value;
                      }),
                      autofocus: true,
                      controller: _textController,
                    ),
                  ),
          ),
          ListTile(
            title: Text(
              "Select an option or create one",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            dense: true,
          ),
          Expanded(
            child: ListView(
              children: [
                for (final tag in filteredTags) ...[
                  Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      onTap: () => setState(() {
                        _selectedTags.add(tag);
                        filter = "";
                        _focusNode.requestFocus();
                        _textController.clear();

                        if (widget.onTagSelected != null) {
                          widget.onTagSelected!(tag.$1);
                        }
                      }),
                      leading:
                          const Icon(Icons.drag_indicator, color: Colors.grey),
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          label: Text(tag.$1),
                          backgroundColor: tag.$2,
                        ),
                      ),
                    ),
                  ),
                ],
                if (filter.isNotEmpty &&
                    (filteredTags.isEmpty || filteredTags.first.$1 != filter))
                  Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      selected: true,
                      selectedColor: Colors.red,
                      onTap: () => setState(() {
                        _selectedTags.add((filter, Colors.yellow.shade200));

                        widget.onTagCreated(filter);

                        filter = "";
                        _focusNode.requestFocus();
                        _textController.clear();
                      }),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Create",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(filter),
                            backgroundColor: Colors.yellow.shade200,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
