import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../l10n/app_localizations.dart';
import '../../models/category_detail_data.dart';
import '../../models/idea_attachment.dart';
import '../../services/service_locator.dart';
import '../../utils/turnstile.dart';

class IdeasSection extends StatefulWidget {
  final AppLocalizations l10n;
  final List<CategoryDetailData> categories;
  final CategoryDetailData? initialCategory;
  final String? initialContext;

  const IdeasSection({
    super.key,
    required this.l10n,
    required this.categories,
    this.initialCategory,
    this.initialContext,
  });

  @override
  State<IdeasSection> createState() => _IdeasSectionState();
}

class _IdeasSectionState extends State<IdeasSection> {
  static const int _maxAttachments = 10;
  static const int _maxAttachmentSizeBytes = 95 * 1024 * 1024;

  final TextEditingController _ideaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final List<IdeaAttachment> _attachments = [];

  bool _isSubmitting = false;
  String? _successBanner;
  CategoryDetailData? _selectedCategory;

  String? _contextChip;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    if (widget.initialContext != null) {
      _contextChip = widget.initialContext;
      _ideaController.text =
          '${widget.l10n.webIdeasTemplateFinding(widget.initialContext!)}\n\n${widget.l10n.webIdeasTemplateSolution}\n';
    } else {
      final templateCategory = widget.initialCategory?.title;
      if (templateCategory != null) {
        _ideaController.text =
            '${widget.l10n.webIdeasTemplateCategory(templateCategory)}\n\n${widget.l10n.webIdeasTemplateProblem}\n\n${widget.l10n.webIdeasTemplateSolution}\n';
      }
    }
    _ideaController.selection = TextSelection.collapsed(
      offset: _ideaController.text.length,
    );
    _emailController.text = ServiceLocator().settingsManager.email;
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        _persistEmailDraft();
      }
    });
  }

  @override
  void didUpdateWidget(covariant IdeasSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != null &&
        widget.initialCategory?.categoryKey != _selectedCategory?.categoryKey) {
      _selectedCategory = widget.initialCategory;
    }
  }

  @override
  void dispose() {
    _ideaController.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _ideaController.text.trim();
    final hasMinChars = text.length >= 10;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.l10n.ideasTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.l10n.ideasSubtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.l10n.ideasCategoryLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory?.categoryKey,
                decoration: _formDecoration(),
                dropdownColor: const Color(0xFF0B2035),
                iconEnabledColor: Colors.white70,
                items: widget.categories
                    .map((c) => DropdownMenuItem<String>(
                          value: c.categoryKey,
                          child: Text(c.title),
                        ))
                    .toList(growable: false),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedCategory = widget.categories
                              .firstWhere((c) => c.categoryKey == value);
                        });
                      },
              ),
              if (_contextChip != null) ...[
                const SizedBox(height: 14),
                Chip(
                  avatar: const Text('💡'),
                  label: Text(
                    widget.l10n.webIdeasBasedOn(
                      _contextChip!.length > 60
                          ? '${_contextChip!.substring(0, 60)}…'
                          : _contextChip!,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => setState(() => _contextChip = null),
                  backgroundColor: const Color(0x1F38BDF8),
                  side: const BorderSide(color: Color(0x4038BDF8)),
                  labelStyle: const TextStyle(color: Color(0xFF38BDF8)),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                '${widget.l10n.ideasIdeaLabel} (${widget.l10n.ideasMinChars})',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _ideaController,
                enabled: !_isSubmitting,
                minLines: 18,
                maxLines: 34,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: _formDecoration().copyWith(
                  hintText: widget.l10n.categoryDetailBrainstormPlaceholder,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    widget.l10n.webIdeasCharacterStatus(
                      text.length,
                      widget.l10n.ideasMinChars,
                    ),
                    style: TextStyle(
                      color: hasMinChars
                          ? const Color(0xFF7FFFD4)
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _isSubmitting ? null : _pickAttachments,
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      widget.l10n.ideasAttachmentsLabel(_attachments.length),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isSubmitting ? null : _pickAttachments,
                          icon: const Icon(Icons.add),
                          label: Text(widget.l10n.ideasAddFiles),
                        ),
                        Text(
                          widget.l10n.ideasAttachHint,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_attachments.isEmpty)
                      Text(
                        widget.l10n.ideasNoAttachments,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55)),
                      )
                    else
                      ..._attachments.asMap().entries.map((entry) {
                        final i = entry.key;
                        final file = entry.value;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            file.name,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            onPressed: _isSubmitting
                                ? null
                                : () =>
                                    setState(() => _attachments.removeAt(i)),
                            icon:
                                const Icon(Icons.close, color: Colors.white70),
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.l10n.ideasEmailInlineHint,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  _persistEmailDraft();
                  FocusScope.of(context).unfocus();
                },
                style: const TextStyle(color: Colors.white),
                decoration: _formDecoration().copyWith(
                  hintText: widget.l10n.ideasEmailInlinePlaceholder,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: Text(
                    _isSubmitting
                        ? widget.l10n.ideasSubmitting
                        : widget.l10n.categoryDetailBrainstormSubmit,
                  ),
                ),
              ),
              if (_successBanner != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.green.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.greenAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successBanner!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _formDecoration() {
    return InputDecoration(
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF7FFFD4), width: 1.2),
      ),
    );
  }

  Future<void> _pickAttachments() async {
    if (_attachments.length >= _maxAttachments) {
      _showSnack(widget.l10n.webIdeasMaxAttachments(_maxAttachments));
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'mp4',
        'mov',
        'pdf',
        'txt',
        'csv',
        'doc',
        'docx',
        'm4a',
        'mp3',
        'wav',
        'ogg',
        'aac',
      ],
    );

    if (result == null || result.files.isEmpty || !mounted) return;

    final incoming = <IdeaAttachment>[];
    for (final file in result.files) {
      final safePath = kIsWeb ? '' : (file.path ?? '');
      final ext =
          (file.extension ?? p.extension(file.name).replaceFirst('.', ''))
              .toLowerCase();

      final bytes = file.bytes;
      final size = file.size;
      if (size > _maxAttachmentSizeBytes) {
        _showSnack(
          widget.l10n.webIdeasFileTooLarge(
            file.name,
            _maxAttachmentSizeBytes ~/ (1024 * 1024),
          ),
        );
        continue;
      }

      incoming.add(
        IdeaAttachment(
          path: safePath,
          name: file.name,
          mimeType: mimeFromExtension(ext),
          type: attachmentTypeFromExtension(ext),
          bytes: bytes,
          sizeBytes: size,
        ),
      );
    }

    setState(() {
      final availableSlots = _maxAttachments - _attachments.length;
      _attachments.addAll(incoming.take(availableSlots));
    });
  }

  Future<void> _submit() async {
    final text = _ideaController.text.trim();
    if (text.length < 10 && _attachments.isEmpty) {
      _showSnack(widget.l10n.categoryDetailBrainstormMinLength);
      return;
    }

    final email = _emailController.text.trim();
    if (email.isNotEmpty && !_isValidEmail(email)) {
      _showSnack(widget.l10n.profileEmailInvalid);
      return;
    }

    if (_selectedCategory == null) {
      _showSnack(widget.l10n.selectCategoryFirst);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _persistEmailDraft();

      final turnstileToken = await getTurnstileToken();
      if (turnstileToken == null || turnstileToken.isEmpty) {
        if (mounted) _showSnack(widget.l10n.categoryDetailBrainstormError);
        return;
      }

      final result = await ServiceLocator().apiService.submitIdea(
            description: text,
            category: _selectedCategory!.categoryKey,
            attachments: List<IdeaAttachment>.from(_attachments),
            email: email.isEmpty ? null : email,
            turnstileToken: turnstileToken,
          );

      if (!mounted) return;
      if (result['success'] == true) {
        _ideaController.clear();
        _attachments.clear();
        setState(() => _successBanner = widget.l10n.ideasSuccess);
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _successBanner = null);
        });
      } else {
        _showSnack(result['message']?.toString() ??
            widget.l10n.categoryDetailBrainstormError);
      }
    } catch (_) {
      if (mounted) _showSnack(widget.l10n.categoryDetailBrainstormError);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _persistEmailDraft() async {
    final email = _emailController.text.trim();
    final current = ServiceLocator().settingsManager.email.trim();
    if (email == current) return;

    await ServiceLocator().settingsManager.setEmail(email);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
