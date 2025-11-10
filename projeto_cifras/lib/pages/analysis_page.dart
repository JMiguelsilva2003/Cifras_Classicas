import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:projeto_cifras/analysis/frequency_analyzer.dart';
import 'dart:math';
import 'package:projeto_cifras/analysis/analysis_service.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final TextEditingController _originalController = TextEditingController();
  final TextEditingController _cipheredController = TextEditingController();

  final FrequencyAnalyzer _analyzer = FrequencyAnalyzer();

  Map<String, double> _originalFreq = {};
  Map<String, double> _cipheredFreq = {};

  @override
  void initState() {
    super.initState();
    AnalysisService.instance.textPair.addListener(_updateFieldsFromService);
    
    _updateFieldsFromService();
  }

  @override
  void dispose() {
    AnalysisService.instance.textPair.removeListener(_updateFieldsFromService);
    _originalController.dispose();
    _cipheredController.dispose();
    super.dispose();
  }
  void _updateFieldsFromService() {
    final pair = AnalysisService.instance.textPair.value;
    _originalController.text = pair.original;
    _cipheredController.text = pair.ciphered;
  }

  void _analyze() {
    setState(() {
      _originalFreq = _analyzer.calculate(_originalController.text);
      _cipheredFreq = _analyzer.calculate(_cipheredController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _originalController,
            decoration: const InputDecoration(
              labelText: 'Texto Original',
              hintText: 'Automático ou cole o texto aqui',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cipheredController,
            decoration: const InputDecoration(
              labelText: 'Texto Cifrado',
              hintText: 'Automático ou cole o texto aqui',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.bar_chart),
            label: const Text('Analisar Frequência'),
            onPressed: _analyze,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildChartSection(
            'Frequência do Texto Original',
            _originalFreq,
            Colors.blue,
          ),
          const SizedBox(height: 32),
          _buildChartSection(
            'Frequência do Texto Cifrado',
            _cipheredFreq,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyTable(Map<String, double> data) {
    final entries = data.entries.where((e) => e.value > 0.0).toList();
    if (entries.isEmpty) {
      return const Text(
        'Nenhuma letra (A-Z) encontrada.',
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }
    entries.sort((a, b) => b.value.compareTo(a.value));
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: entries.map((entry) {
        return Chip(
          backgroundColor: Colors.white10,
          label: Text(
            '${entry.key}: ${entry.value.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartSection(
    String title,
    Map<String, double> data,
    Color color,
  ) {
    double maxFreq = 0.0;
    if (data.values.isNotEmpty) {
      maxFreq = data.values.reduce(max);
    }
    double chartMaxY = max(20.0, (maxFreq / 10).ceil() * 10.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('Sumário Numérico (Mais frequentes):', 
          style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _buildFrequencyTable(data),
        const SizedBox(height: 24),
        Text('Gráfico Visual:', 
          style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        
        Container(
          height: 300,
          padding: const EdgeInsets.only(right: 16, top: 16),
          child: BarChart(
            BarChartData(
              maxY: chartMaxY, 
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == 0 ||
                          value == chartMaxY / 2 ||
                          value == chartMaxY) {
                        return Text('${value.toInt()}%',
                            style: const TextStyle(fontSize: 10));
                      }
                      return const Text('');
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      String text = String.fromCharCode(index + 65);
                      return SideTitleWidget(
                        meta: meta,
                        angle: -pi / 2,
                        child: Text(text, style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: data.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final percentage = entry.value.value;
                return BarChartGroupData(
                  x: index, 
                  barRods: [
                    BarChartRodData(
                      toY: percentage, 
                      color: color,
                      width: 10,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}