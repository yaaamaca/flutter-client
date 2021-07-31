import 'package:flutter/material.dart';

bool typeSendMessage(String type) =>
    type.startsWith("message.") || type.startsWith("channel.");
bool typeSendChannel(String type) => type == "channel_group";
bool typeSendChannelGroup(String type) => type == "channel_group";
bool typeSendReaction(String type) => type.startsWith("message.");
bool typeReveseView(String type) =>
    type.startsWith("message.") || type.startsWith("channel.");
bool typeShowEmbedChildren(String type) => type == "channel_group";

IconData typeIcon(String? type) => type == "channel.message"
    ? Icons.tag_rounded
    : (type == "channel_group"
        ? Icons.folder
        : (type == "message.text" ? Icons.message : Icons.device_unknown));
