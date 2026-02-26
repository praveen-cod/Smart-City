// lib/features/citizen/screens/report_issue_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/widgets/category_chip.dart';
import '../../issues/models/category.dart';
import '../../issues/models/issue.dart';
import '../../issues/models/issue_status.dart';
import '../../issues/models/location.dart';
import '../../issues/providers/issue_providers.dart';
import '../../auth/controllers/auth_controller.dart';

class ReportIssueScreen extends ConsumerStatefulWidget {
  const ReportIssueScreen({super.key});
  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  int _step = 0;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _wardCtrl = TextEditingController();
  IssueCategory? _selectedCategory;
  bool _submitting = false;
  final List<String> _mockPhotos = [];
  bool _locationFilled = false;

  final _steps = ['Category', 'Details', 'Location', 'Photos'];

  bool get _canProceed {
    switch (_step) {
      case 0: return _selectedCategory != null;
      case 1: return _titleCtrl.text.trim().isNotEmpty && _descCtrl.text.trim().length >= 10;
      case 2: return _areaCtrl.text.trim().isNotEmpty;
      case 3: return true;
      default: return false;
    }
  }

  void _nextStep() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final auth = ref.read(authControllerProvider);
    final repo = ref.read(issueRepositoryProvider);
    final now = DateTime.now();

    final issue = Issue(
      id: 'issue_${const Uuid().v4().substring(0, 8)}',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _selectedCategory!,
      location: IssueLocation(
        areaName: _areaCtrl.text.trim(),
        wardNumber: _wardCtrl.text.trim().isEmpty ? 'N/A' : _wardCtrl.text.trim(),
      ),
      status: IssueStatus.open,
      createdAt: now,
      updatedAt: now,
      reporterId: auth.user?.id ?? 'user_default',
      reporterName: auth.user?.name ?? '',
      attachments: _mockPhotos,
    );

    repo.createIssue(issue);

    if (!mounted) return;
    setState(() => _submitting = false);

    // Success bottom sheet
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _SuccessSheet(
        onDone: () {
          Navigator.pop(ctx);
          context.go('/citizen/my-issues');
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _areaCtrl.dispose();
    _wardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Issue'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              context.go('/citizen/home');
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(_steps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  return Expanded(
                    child: Container(
                      height: 2,
                      color: i ~/ 2 < _step ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  );
                }
                final stepIdx = i ~/ 2;
                final done = stepIdx < _step;
                final active = stepIdx == _step;
                return Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: done || active ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: done
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                          : Center(
                              child: Text(
                                '${stepIdx + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: active ? Colors.white : scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _steps[stepIdx],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                        color: active ? scheme.primary : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 8),

          // Step content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: SingleChildScrollView(
                key: ValueKey(_step),
                padding: const EdgeInsets.all(16),
                child: _buildStep(context),
              ),
            ),
          ),

          // Bottom nav
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _canProceed && !_submitting ? _nextStep : null,
                    child: _submitting
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_step == _steps.length - 1 ? 'Submit Issue' : 'Continue'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case 0: return _CategoryStep(selected: _selectedCategory, onSelect: (c) => setState(() => _selectedCategory = c));
      case 1: return _DetailsStep(titleCtrl: _titleCtrl, descCtrl: _descCtrl, onChanged: () => setState(() {}));
      case 2: return _LocationStep(areaCtrl: _areaCtrl, wardCtrl: _wardCtrl, locationFilled: _locationFilled,
            onUseCurrent: () => setState(() {
              _areaCtrl.text = 'Koramangala, 80 Feet Road';
              _wardCtrl.text = '12';
              _locationFilled = true;
            }), onChanged: () => setState(() {}));
      case 3: return _PhotoStep(photos: _mockPhotos, onAdd: () => setState(() => _mockPhotos.add('mock_${_mockPhotos.length}')));
      default: return const SizedBox();
    }
  }
}

class _CategoryStep extends StatelessWidget {
  final IssueCategory? selected;
  final void Function(IssueCategory) onSelect;
  const _CategoryStep({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Category', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('What type of issue are you reporting?', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemCount: IssueCategories.all.length,
          itemBuilder: (_, i) {
            final cat = IssueCategories.all[i];
            return CategoryGridTile(
              category: cat,
              selected: selected?.id == cat.id,
              onTap: () => onSelect(cat),
            );
          },
        ),
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final VoidCallback onChanged;
  const _DetailsStep({required this.titleCtrl, required this.descCtrl, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Issue Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Describe the issue clearly.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 20),
        TextFormField(
          controller: titleCtrl,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(labelText: 'Issue Title *', hintText: 'e.g. Deep pothole on main road'),
          textCapitalization: TextCapitalization.sentences,
          maxLength: 80,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descCtrl,
          onChanged: (_) => onChanged(),
          maxLines: 5,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: 'Description *',
            hintText: 'Describe the issue in detail. Include any safety concerns.',
            alignLabelWithHint: true,
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}

class _LocationStep extends StatelessWidget {
  final TextEditingController areaCtrl;
  final TextEditingController wardCtrl;
  final bool locationFilled;
  final VoidCallback onUseCurrent;
  final VoidCallback onChanged;
  const _LocationStep({required this.areaCtrl, required this.wardCtrl, required this.locationFilled, required this.onUseCurrent, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Where is the issue located?', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 20),

        // Mock map
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4F8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Stack(
            children: [
              // Grid lines
              CustomPaint(painter: _GridPainter(), size: Size.infinite),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_pin, size: 36, color: scheme.primary),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(100)),
                      child: Text(
                        locationFilled ? areaCtrl.text : 'Tap to pin location',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: onUseCurrent,
          icon: const Icon(Icons.my_location_rounded, size: 18),
          label: const Text('Use Current Location (Mock)'),
        ),

        const SizedBox(height: 20),

        TextFormField(
          controller: areaCtrl,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(labelText: 'Area / Street *', prefixIcon: Icon(Icons.location_on_outlined), hintText: 'e.g. Koramangala 5th Block'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: wardCtrl,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(labelText: 'Ward Number', prefixIcon: Icon(Icons.numbers_rounded), hintText: 'e.g. 12'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PhotoStep extends StatelessWidget {
  final List<String> photos;
  final VoidCallback onAdd;
  const _PhotoStep({required this.photos, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attach Photos (Optional)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Add up to 3 photos to support your report.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 20),
        Row(
          children: [
            _PhotoButton(icon: Icons.camera_alt_rounded, label: 'Camera', onTap: onAdd),
            const SizedBox(width: 12),
            _PhotoButton(icon: Icons.photo_library_rounded, label: 'Gallery', onTap: onAdd),
          ],
        ),
        if (photos.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('${photos.length} photo(s) selected', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: photos.map((p) => _PhotoThumbnail(key: ValueKey(p))).toList(),
          ),
        ],
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: scheme.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Photo uploads are mocked. In production, this will use the device camera and gallery.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PhotoButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4), style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(height: 6),
              Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.image_rounded, color: scheme.primary, size: 32),
    );
  }
}

class _SuccessSheet extends StatelessWidget {
  final VoidCallback onDone;
  const _SuccessSheet({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 44),
          ),
          const SizedBox(height: 20),
          const Text('Issue Reported!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'Your issue has been submitted successfully. Our team will review it shortly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 28),
          FilledButton(onPressed: onDone, child: const Text('View My Issues')),
        ],
      ),
    );
  }
}
