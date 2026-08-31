import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final String? navRoute;
  final String? navLabel;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.navRoute,
    this.navLabel,
  });
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _categoriaSeleccionada = "🧮 Fórmulas";

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: """👋 ¡Hola! Soy **DrillBot 2.0**, tu Asistente Técnico Operacional de Terreno.

💡 **¿En qué puedo ayudarte hoy?**
• **🧮 Cálculos automáticos:** Escribe por ejemplo 'contra anterior 0.80 agregue barra 3.00 avance 1.50' o 'perfore 1.50 y recupere 1.42'.
• **🚨 Diagnósticos de Terreno:** Pregúntame sobre 'testigo quemado', 'perdida de agua', 'overshot no engancha', 'caida de presion'.
• **🛠️ Metrajes & Normas:** Metrajes de barras, barriles NQ/HQ/PQ, punto muerto y rotulación de cajas.""",
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
    Future.delayed(const Duration(milliseconds: 250), () {
      final match = ChatbotKnowledgeService.buscarRespuesta(query);
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: match['response'] as String,
            isUser: false,
            timestamp: DateTime.now(),
            navRoute: match['navRoute'] as String?,
            navLabel: match['navLabel'] as String?,
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
    final categorias = ChatbotKnowledgeService.obtenerCategoriasSugerencias();

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DrillBot 2.0 — Asistente",
                  style: TextStyle(
                    color: colors.azulOscuro,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Inteligencia operacional de terreno",
                  style: TextStyle(
                    color: colors.grisTexto,
                    fontSize: 10.5,
                  ),
                ),
              ],
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
          // 1. Selector de Categorías Temáticas
          Container(
            height: 42,
            color: colors.superficieSuave,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              children: categorias.keys.map((cat) {
                final esSelec = cat == _categoriaSeleccionada;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => setState(() => _categoriaSeleccionada = cat),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: esSelec ? colors.azul : colors.superficie,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: esSelec ? colors.azul : colors.bordeSuave,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: esSelec ? Colors.white : colors.azulOscuro,
                            fontSize: 11.5,
                            fontWeight: esSelec ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 2. Chips Bar de Preguntas Frecuentes de la Categoría Activa
          Container(
            height: 44,
            color: colors.superficie,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              children: (categorias[_categoriaSeleccionada] ?? []).map((sug) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ActionChip(
                    backgroundColor: colors.azulClaro,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    label: Text(
                      sug,
                      style: TextStyle(
                        color: colors.azul,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _sendMessage(sug),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // 3. Historial de Conversación
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

          // 4. Barra Inferior de Entrada
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.superficie,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                        hintText: "Ej: contra anterior 0.80 agregué 3.00 avance 1.50...",
                        hintStyle: TextStyle(color: colors.grisTexto, fontSize: 12.5),
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
                border: Border.all(
                  color: isUser ? colors.azul : colors.bordeSuave,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isUser
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
                  if (!isUser) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (msg.navRoute != null && msg.navLabel != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => widget.onNavigate(msg.navRoute!),
                              icon: const Icon(Icons.arrow_forward_ios, size: 12),
                              label: Text(
                                msg.navLabel!,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.azul,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        IconButton(
                          icon: Icon(Icons.copy, size: 15, color: colors.grisSecundario),
                          tooltip: "Copiar texto",
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: msg.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Respuesta copiada al portapapeles"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
