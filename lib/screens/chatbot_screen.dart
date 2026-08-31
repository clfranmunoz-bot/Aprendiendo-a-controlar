import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/widgets/drawer_menu.dart';
import 'package:aprender_a_controlar/services/chatbot_knowledge_service.dart';
import 'package:aprender_a_controlar/screens/ejercicios/ejercicios_helpers.dart';

class ChatbotScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;

  const ChatbotScreen({
    super.key,
    required this.onNavigate,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "👋 ¡Hola! Soy **DrillBot**, un asistente básico de apoyo operacional.\n\n"
          "Estoy programado para responder **preguntas sencillas y directas** sobre metrajes de herramientas (barras, barriles, extensión Reflex), fórmulas de control y listas de procedimientos o documentos obligatorios de la app.\n\n"
          "Para evitar confusiones en terreno, si no comprendo una duda te pediré consultarla con tu Supervisor.",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  void _sendMessage(String text) {
    final query = text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: query,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _inputController.clear();
    _scrollToBottom();

    // Process Bot Response
    Future.delayed(const Duration(milliseconds: 300), () {
      final match = ChatbotKnowledgeService.buscarRespuesta(query);
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: match['response'] as String,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final sugerencias = ChatbotKnowledgeService.obtenerSugerenciasRapidas();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.fondo,
      appBar: AppBar(
        backgroundColor: colors.superficie,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: colors.azulOscuro),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            const Text("🤖 ", style: TextStyle(fontSize: 22)),
            Text(
              "DrillBot — Asistente",
              style: TextStyle(
                color: colors.azulOscuro,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home_outlined, color: colors.azulOscuro),
            tooltip: "Volver al Inicio",
            onPressed: () => widget.onNavigate('home'),
          ),
        ],
      ),
      drawer: DrawerMenu(
        onNavigate: widget.onNavigate,
        modoOscuro: widget.modoOscuro,
        onToggleModoOscuro: widget.onToggleModoOscuro,
      ),
      body: Column(
        children: [
          // Chips Bar of Quick Suggestions
          Container(
            height: 48,
            color: colors.superficie,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: sugerencias.length,
              itemBuilder: (context, idx) {
                final sug = sugerencias[idx];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    backgroundColor: colors.azulClaro,
                    side: BorderSide.none,
                    label: Text(
                      sug,
                      style: TextStyle(
                        color: colors.azul,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _sendMessage(sug),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Messages History
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                return _buildMessageBubble(msg, colors);
              },
            ),
          ),

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.superficie,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: "Escribe tu pregunta sobre sondaje...",
                        filled: true,
                        fillColor: colors.fondo,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: colors.bordeSuave),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: colors.bordeSuave),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: colors.azul,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: () => _sendMessage(_inputController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg, AppColors colors) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF2563EB),
              child: Text("🤖", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? colors.azul
                    : (colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: isUser
                  ? Text(
                      msg.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : textWithLatex(
                      colors,
                      msg.text,
                      style: TextStyle(
                        color: colors.azulOscuro,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
