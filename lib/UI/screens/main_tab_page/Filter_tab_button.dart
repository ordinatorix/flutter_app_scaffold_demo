import 'package:flutter/material.dart';
import 'package:flutter_scaffold/enums/filtered_options.dart';
import 'package:flutter_scaffold/generated/i18n.dart';

class FilterButton extends StatelessWidget {
  final Function onTap;
  final FilteredOptions displayValue;

  FilterButton({
    @required this.onTap,
    @required this.displayValue,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      dropdownColor: Theme.of(context).primaryColor,
      onChanged: (FilteredOptions selectedValue) {
        onTap(selectedValue);
      },
      value: displayValue,
      items: [
        DropdownMenuItem(
          child: Text(
            I18n.of(context).showAll,
            style: Theme.of(context).textTheme.button,
          ),
          value: FilteredOptions.All,
        ),
        DropdownMenuItem(
          child: Text(
            I18n.of(context).showConfirmed,
            style: Theme.of(context).textTheme.button,
          ),
          value: FilteredOptions.Confirmed,
        ),
        DropdownMenuItem(
          child: Text(
            I18n.of(context).showRumored,
            style: Theme.of(context).textTheme.button,
          ),
          value: FilteredOptions.Rumored,
        ),
        DropdownMenuItem(
          child: Text(
            I18n.of(context).showCleared,
            style: Theme.of(context).textTheme.button,
          ),
          value: FilteredOptions.Cleared,
        ),
        DropdownMenuItem(
          child: Text(
            I18n.of(context).showFake,
            style: Theme.of(context).textTheme.button,
          ),
          value: FilteredOptions.Fake,
        ),
      ],
    );
  }
}
