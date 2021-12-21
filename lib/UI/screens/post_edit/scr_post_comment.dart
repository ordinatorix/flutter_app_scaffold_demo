import 'package:flutter/material.dart';

import '../../../generated/i18n.dart';

import 'mdl_post_comment.dart';

import '../../base_view_screen.dart';

import '../../../logger.dart';

final log = getLogger('PostCommentScreen');

class PostCommentScreen extends StatelessWidget {
  static const routeName = '/post-comment-screen';
  @override
  Widget build(BuildContext context) {
    log.i('building post comment screen');
    final _args = ModalRoute.of(context).settings.arguments as List;
    return BaseView<PostCommentScreenViewModel>(
      onModelDisposing: (model) {
        model.disposer();
      },
      builder: (context, model, child) {
        return Scaffold(
          key: model.scaffoldKey,
          appBar: AppBar(
            title: Text(
              I18n.of(context).postCommentScreenTitle,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Form(
              key: model.form,
              child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  TextFormField(
                    initialValue: _args != null ? _args[0]['text'] : '',
                    decoration: InputDecoration(
                      labelText: I18n.of(context).postCommentScreenLabelText,
                      labelStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: 10,
                    validator: (value) {
                      if (value.isEmpty) {
                        return I18n.of(context)
                            .postCommentScreenNoCommentWarning;
                      } else if (RegExp('[a-zA-Z]').hasMatch(value)) {
                        return null;
                      } else {
                        return I18n.of(context)
                            .postCommentScreenInvalidCommentWarning;
                      }
                    },
                    onSaved: (value) {
                      model.comment = [
                        {
                          'timestamp': null,
                          'text': value,
                        }
                      ];
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.check),
                    label: Text(I18n.of(context).buttonsDoneButton),
                    onPressed: model.validateComment,
                  )
                ]),
              ),
            ),
          ),
        );
      },
    );
  }
}
