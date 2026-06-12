// file: lib/shared/widgets/tables/ac_data_table.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../states/ac_states.dart';

// ─── Column definition ───────────────────────────────────────────────────
class AcTableColumn<T> {
  const AcTableColumn({
    required this.key,
    required this.label,
    required this.cellBuilder,
    this.width,
    this.isSortable = false,
    this.flex = 1,
  });

  final String key;
  final String label;
  final Widget Function(T row, int index) cellBuilder;
  final double? width;
  final bool isSortable;
  final int flex;
}

// ─── Sort state ───────────────────────────────────────────────────────────
class AcTableSort {
  const AcTableSort({required this.columnKey, required this.ascending});

  final String columnKey;
  final bool ascending;
}

// ─── AcDataTable ─────────────────────────────────────────────────────────
class AcDataTable<T> extends StatefulWidget {
  const AcDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onSort,
    this.currentSort,
    this.isLoading = false,
    this.emptyTitle = 'لا توجد بيانات',
    this.emptyMessage,
    this.emptyIcon,
    this.onRowTap,
    this.selectedRows,
    this.onRowSelected,
    this.showCheckboxes = false,
    this.stickyHeader = true,
    this.rowHeight = 56.0,
  });

  final List<AcTableColumn<T>> columns;
  final List<T> rows;
  final void Function(String columnKey, bool ascending)? onSort;
  final AcTableSort? currentSort;
  final bool isLoading;
  final String emptyTitle;
  final String? emptyMessage;
  final Widget? emptyIcon;
  final void Function(T row, int index)? onRowTap;
  final Set<int>? selectedRows;
  final void Function(int index, bool selected)? onRowSelected;
  final bool showCheckboxes;
  final bool stickyHeader;
  final double rowHeight;

  @override
  State<AcDataTable<T>> createState() => _AcDataTableState<T>();
}

class _AcDataTableState<T> extends State<AcDataTable<T>> {
  Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedRows ?? {};
  }

  void _toggleAll(bool? v) {
    setState(() {
      if (v == true) {
        _selected = Set.from(Iterable.generate(widget.rows.length));
      } else {
        _selected = {};
      }
    });
  }

  void _toggleRow(int i, bool? v) {
    setState(() {
      if (v == true) {
        _selected.add(i);
      } else {
        _selected.remove(i);
      }
    });
    widget.onRowSelected?.call(i, v ?? false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.brCard,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [_buildHeader(), const AcListSkeleton(itemCount: 6)],
        ),
      );
    }

    if (widget.rows.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.brCard,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            _buildHeader(),
            AcEmptyState(
              title: widget.emptyTitle,
              message: widget.emptyMessage,
              icon: widget.emptyIcon ?? const Icon(Icons.table_rows_outlined),
              size: AcStateSize.medium,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalFixedWidth = widget.columns
            .where((c) => c.width != null)
            .fold(0.0, (sum, c) => sum + c.width!);
        final paddingPerColumn = 2 * AppSpacing.md; // horizontal padding per column
        final totalPadding = widget.columns.length * paddingPerColumn;
        final minTableWidth = totalFixedWidth + totalPadding + 200;

        final needsHorizontalScroll = constraints.maxWidth < minTableWidth;

        Widget table = _buildTable();

        if (needsHorizontalScroll) {
          table = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: math.max(constraints.maxWidth, minTableWidth),
              child: table,
            ),
          );
        }

        return table;
      },
    );
  }

  Widget _buildHeader() {
    final allSelected =
        _selected.length == widget.rows.length && widget.rows.isNotEmpty;
    final someSelected =
        _selected.isNotEmpty && _selected.length < widget.rows.length;

    return Container(
      color: AppColors.neutral50,
      height: 48,
      child: Row(
        children: [
          if (widget.showCheckboxes)
            SizedBox(
              width: 48,
              child: Checkbox(
                value: allSelected ? true : (someSelected ? null : false),
                tristate: true,
                onChanged: _toggleAll,
              ),
            ),
          ...widget.columns.map((col) => _buildHeaderCell(col)),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(AcTableColumn<T> col) {
    final isSorted = widget.currentSort?.columnKey == col.key;
    final ascending = widget.currentSort?.ascending ?? true;

    Widget cell = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            col.label,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (col.isSortable) ...[
            const SizedBox(width: AppSpacing.xxs),
            Icon(
              isSorted
                  ? (ascending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded)
                  : Icons.unfold_more_rounded,
              size: 14,
              color: isSorted ? AppColors.primary500 : AppColors.textMuted,
            ),
          ],
        ],
      ),
    );

    if (col.isSortable && widget.onSort != null) {
      cell = InkWell(
        onTap: () => widget.onSort!(col.key, isSorted ? !ascending : true),
        child: cell,
      );
    }

    if (col.width != null) {
      return SizedBox(width: col.width, child: cell);
    }
    return Expanded(flex: col.flex, child: cell);
  }

  Widget _buildRow(int i) {
    final row = widget.rows[i];
    final isSelected = _selected.contains(i);

    return InkWell(
      onTap: widget.onRowTap != null ? () => widget.onRowTap!(row, i) : null,
      hoverColor: AppColors.neutral50,
      splashColor: AppColors.primary50,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: widget.rowHeight,
        color: isSelected ? AppColors.primary50 : Colors.transparent,
        child: Row(
          children: [
            if (widget.showCheckboxes)
              SizedBox(
                width: 48,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (v) => _toggleRow(i, v),
                ),
              ),
            ...widget.columns.map((col) {
              final cell = col.cellBuilder(row, i);
              if (col.width != null) {
                return SizedBox(
                  width: col.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: cell,
                  ),
                );
              }
              return Expanded(
                flex: col.flex,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: cell,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brCard,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: widget.rows.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (_, i) => _buildRow(i),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AcPagination ────────────────────────────────────────────────────────
class AcPagination extends StatelessWidget {
  const AcPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.totalItems,
    this.itemsPerPage = 20,
    this.onItemsPerPageChanged,
    this.pageSizeOptions = const [10, 20, 50, 100],
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final int? totalItems;
  final int itemsPerPage;
  final ValueChanged<int>? onItemsPerPageChanged;
  final List<int> pageSizeOptions;

  List<int> get _visiblePages {
    const maxVisible = 5;
    if (totalPages <= maxVisible) {
      return List.generate(totalPages, (i) => i + 1);
    }
    int start = (currentPage - 2).clamp(1, totalPages - maxVisible + 1);
    return List.generate(maxVisible, (i) => start + i);
  }

  @override
  Widget build(BuildContext context) {
    final start = (currentPage - 1) * itemsPerPage + 1;
    final end = (currentPage * itemsPerPage).clamp(0, totalItems ?? 0);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Items per page
          if (onItemsPerPageChanged != null) ...[
            Text('عرض', style: AppTypography.bodySmall),
            const SizedBox(width: AppSpacing.xs),
            DropdownButton<int>(
              value: itemsPerPage,
              items: pageSizeOptions
                  .map(
                    (n) => DropdownMenuItem(
                      value: n,
                      child: Text('$n', style: AppTypography.bodySmall),
                    ),
                  )
                  .toList(),
              onChanged: (v) => onItemsPerPageChanged!(v ?? itemsPerPage),
              underline: const SizedBox(),
              isDense: true,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],

          // Item count
          if (totalItems != null)
            Text('$start-$end من $totalItems', style: AppTypography.bodySmall),

          const Spacer(),

          // Page buttons
          Row(
            children: [
              _PageBtn(
                icon: Icons.chevron_right_rounded,
                onTap: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),
              ..._visiblePages.map(
                (p) => _PageBtn(
                  label: '$p',
                  isSelected: p == currentPage,
                  onTap: () => onPageChanged(p),
                ),
              ),
              _PageBtn(
                icon: Icons.chevron_left_rounded,
                onTap: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  const _PageBtn({this.label, this.icon, this.onTap, this.isSelected = false});

  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brXs,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary500 : Colors.transparent,
            borderRadius: AppRadius.brXs,
            border: isSelected ? null : Border.all(color: AppColors.border),
          ),
          child: Center(
            child: label != null
                ? Text(
                    label!,
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected
                          ? AppColors.neutral0
                          : (onTap == null
                                ? AppColors.textDisabled
                                : AppColors.textSecondary),
                    ),
                  )
                : Icon(
                    icon!,
                    size: 16,
                    color: onTap == null
                        ? AppColors.textDisabled
                        : AppColors.textSecondary,
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── AcTableWithPagination ────────────────────────────────────────────────
class AcTableWithPagination<T> extends StatelessWidget {
  const AcTableWithPagination({
    super.key,
    required this.columns,
    required this.rows,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.totalItems,
    this.itemsPerPage = 20,
    this.onSort,
    this.currentSort,
    this.isLoading = false,
    this.onRowTap,
    this.showCheckboxes = false,
    this.selectedRows,
    this.onRowSelected,
    this.emptyTitle = 'لا توجد بيانات',
    this.emptyMessage,
    this.onItemsPerPageChanged,
  });

  final List<AcTableColumn<T>> columns;
  final List<T> rows;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final int? totalItems;
  final int itemsPerPage;
  final void Function(String, bool)? onSort;
  final AcTableSort? currentSort;
  final bool isLoading;
  final void Function(T, int)? onRowTap;
  final bool showCheckboxes;
  final Set<int>? selectedRows;
  final void Function(int, bool)? onRowSelected;
  final String emptyTitle;
  final String? emptyMessage;
  final ValueChanged<int>? onItemsPerPageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brCard,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AcDataTable<T>(
            columns: columns,
            rows: rows,
            onSort: onSort,
            currentSort: currentSort,
            isLoading: isLoading,
            onRowTap: onRowTap,
            showCheckboxes: showCheckboxes,
            selectedRows: selectedRows,
            onRowSelected: onRowSelected,
            emptyTitle: emptyTitle,
            emptyMessage: emptyMessage,
          ),
          AcPagination(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: onPageChanged,
            totalItems: totalItems,
            itemsPerPage: itemsPerPage,
            onItemsPerPageChanged: onItemsPerPageChanged,
          ),
        ],
      ),
    );
  }
}
