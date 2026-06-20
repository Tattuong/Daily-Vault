import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../models/vault_item.dart';
import '../../providers/shop_provider.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_ui.dart';
import '../main_shell.dart';

class VaultItemFormScreen extends StatefulWidget {
  final VaultItem? item;
  final VaultItemType? type;

  const VaultItemFormScreen({super.key, this.item, this.type});

  @override
  State<VaultItemFormScreen> createState() => _VaultItemFormScreenState();
}

class _VaultItemFormScreenState extends State<VaultItemFormScreen> {
  late final VaultItemType _type;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _notesCtrl;
  bool _obscurePassword = true;
  bool _favorite = false;
  String? _filePath;
  String? _fileName;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _type = item?.type ?? widget.type ?? VaultItemType.password;
    _titleCtrl = TextEditingController(text: item?.title ?? '');
    _usernameCtrl = TextEditingController(text: item?.username ?? '');
    _passwordCtrl = TextEditingController(text: item?.password ?? '');
    _urlCtrl = TextEditingController(text: item?.url ?? '');
    _contentCtrl = TextEditingController(text: item?.content ?? '');
    _notesCtrl = TextEditingController(text: item?.notes ?? '');
    _favorite = item?.favorite ?? false;
    _filePath = item?.filePath;
    _fileName = item?.fileName;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _urlCtrl.dispose();
    _contentCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;
    setState(() {
      _filePath = file.path;
      _fileName = file.name;
    });
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;

    final vault = context.read<VaultProvider>();
    final shop = context.read<ShopProvider>();
    final isNew = widget.item == null;

    if (isNew && !vault.canAdd(_type, unlimited: shop.hasUnlimitedItems)) {
      if (mounted) MainShell.of(context)?.openShop();
      return;
    }

    setState(() => _saving = true);

    String? savedFilePath = _filePath;
    if (_type == VaultItemType.document && isNew && _filePath != null && widget.item?.filePath != _filePath) {
      savedFilePath = await vault.copyDocumentToVault(_filePath!, _fileName ?? 'document');
    }

    await vault.saveItem(
      id: widget.item?.id,
      type: _type,
      title: _titleCtrl.text,
      username: _type == VaultItemType.password ? _usernameCtrl.text : null,
      password: _type == VaultItemType.password ? _passwordCtrl.text : null,
      url: _type == VaultItemType.password ? _urlCtrl.text : null,
      content: _type == VaultItemType.note ? _contentCtrl.text : null,
      filePath: _type == VaultItemType.document ? savedFilePath : null,
      fileName: _type == VaultItemType.document ? _fileName : null,
      notes: _notesCtrl.text,
      favorite: _favorite,
    );

    if (isNew) {
      await shop.rewardForVaultItem(_type);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    AppToast.show(context, title: AppStrings.t(context, 'itemSaved'));
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(context, 'delete')),
        content: Text(AppStrings.t(context, 'deleteConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(context, 'cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.t(context, 'delete'))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await context.read<VaultProvider>().deleteItem(widget.item!.id);
    if (!mounted) return;
    AppToast.show(context, title: AppStrings.t(context, 'itemDeleted'));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      TextField(
        controller: _titleCtrl,
        decoration: InputDecoration(labelText: AppStrings.t(context, 'fieldTitle')),
        textCapitalization: TextCapitalization.sentences,
      ),
      const SizedBox(height: 12),
      if (_type == VaultItemType.password) ...[
        TextField(
          controller: _usernameCtrl,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'fieldUsername')),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: AppStrings.t(context, 'fieldPassword'),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_passwordCtrl.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _passwordCtrl.text));
                      AppToast.show(context, title: AppStrings.t(context, 'passwordCopied'));
                    },
                  ),
                IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _urlCtrl,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'fieldUrl')),
          keyboardType: TextInputType.url,
        ),
      ],
      if (_type == VaultItemType.note) ...[
        TextField(
          controller: _contentCtrl,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'fieldContent')),
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
      if (_type == VaultItemType.document) ...[
        OutlinedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.attach_file_rounded),
          label: Text(_fileName ?? AppStrings.t(context, 'pickFile')),
        ),
        if (_fileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_fileName!, style: const TextStyle(fontSize: 12)),
          ),
      ],
      const SizedBox(height: 12),
      TextField(
        controller: _notesCtrl,
        decoration: InputDecoration(
          labelText: AppStrings.t(context, 'fieldNotes'),
          hintText: AppStrings.t(context, 'fieldNotesHint'),
        ),
        maxLines: 3,
      ),
      const SizedBox(height: 8),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(AppStrings.t(context, 'favorite')),
        value: _favorite,
        onChanged: (v) => setState(() => _favorite = v),
      ),
    ];

    return AppFormScreen(
      title: AppStrings.t(context, widget.item == null ? 'addItem' : 'editItem'),
      saveLabel: _saving ? '...' : AppStrings.t(context, 'save'),
      onSave: _saving ? () {} : _save,
      appBarActions: widget.item != null
          ? [
              IconButton(
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              ),
            ]
          : null,
      children: fields,
    );
  }
}
