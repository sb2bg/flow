import 'package:flow/pages/llm_page.dart';

class MessageResponse {
  String model;
  DateTime createdAt;
  String message;
  bool done;
  int? totalDuration;
  int? loadDuration;
  int? promptEvalCount;
  int? promptEvalDuration;
  int? evalCount;
  int? evalDuration;

  MessageResponse(
      {required this.model,
      required this.createdAt,
      required this.message,
      required this.done,
      this.totalDuration,
      this.loadDuration,
      this.promptEvalCount,
      this.promptEvalDuration,
      this.evalCount,
      this.evalDuration});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      model: json['model'],
      createdAt: DateTime.parse(json['created_at']),
      message: json['message']['content'],
      done: json['done'],
      totalDuration: json['total_duration'],
      loadDuration: json['load_duration'],
      promptEvalCount: json['prompt_eval_count'],
      promptEvalDuration: json['prompt_eval_duration'],
      evalCount: json['eval_count'],
      evalDuration: json['eval_duration'],
    );
  }
}

class MessageRequest {
  final String model;
  final MessageHistory messages;
  final List<String>? images;
  final Options? options;

  MessageRequest({
    required this.model,
    required this.messages,
    this.images,
    this.options,
  });

  Map<String, dynamic> toJson() {
    final history = messages
        .map(
            (message) => {'role': message.$1.toString(), 'content': message.$2})
        .toList();

    if (options?.systemPrompt != null) {
      history
          .insert(0, {'role': 'assistant', 'content': options!.systemPrompt!});
    }

    return {
      'model': model,
      'messages': history,
      'images': images,
      'options': options?.toJson(),
    }..removeWhere((_, value) => value == null || value.isEmpty);
  }
}

class Options {
  final String? systemPrompt;
  final int? numKeep;
  final int? seed;
  final int? numPredict;
  final int? topK;
  final double? topP;
  final double? tfsZ;
  final double? typicalP;
  final int? repeatLastN;
  final double? temperature;
  final double? repeatPenalty;
  final double? presencePenalty;
  final double? frequencyPenalty;
  final int? mirostat;
  final double? mirostatTau;
  final double? mirostatEta;
  final bool? penalizeNewline;
  final List<String>? stop;
  final bool? numa;
  final int? numCtx;
  final int? numBatch;
  final int? numGqa;
  final int? numGpu;
  final int? mainGpu;
  final bool? lowVram;
  final bool? f16Kv;
  final bool? vocabOnly;
  final bool? useMmap;
  final bool? useMlock;
  final bool? embeddingOnly;
  final double? ropeFrequencyBase;
  final double? ropeFrequencyScale;
  final int? numThread;

  Options({
    this.systemPrompt,
    this.numKeep,
    this.seed,
    this.numPredict,
    this.topK,
    this.topP,
    this.tfsZ,
    this.typicalP,
    this.repeatLastN,
    this.temperature,
    this.repeatPenalty,
    this.presencePenalty,
    this.frequencyPenalty,
    this.mirostat,
    this.mirostatTau,
    this.mirostatEta,
    this.penalizeNewline,
    this.stop,
    this.numa,
    this.numCtx,
    this.numBatch,
    this.numGqa,
    this.numGpu,
    this.mainGpu,
    this.lowVram,
    this.f16Kv,
    this.vocabOnly,
    this.useMmap,
    this.useMlock,
    this.embeddingOnly,
    this.ropeFrequencyBase,
    this.ropeFrequencyScale,
    this.numThread,
  });

  factory Options.fromJson(Map<String, dynamic> json) {
    return Options(
      numKeep: json['num_keep'],
      seed: json['seed'],
      numPredict: json['num_predict'],
      topK: json['top_k'],
      topP: json['top_p'].toDouble(),
      tfsZ: json['tfs_z'].toDouble(),
      typicalP: json['typical_p'].toDouble(),
      repeatLastN: json['repeat_last_n'],
      temperature: json['temperature'].toDouble(),
      repeatPenalty: json['repeat_penalty'].toDouble(),
      presencePenalty: json['presence_penalty'].toDouble(),
      frequencyPenalty: json['frequency_penalty'].toDouble(),
      mirostat: json['mirostat'],
      mirostatTau: json['mirostat_tau'].toDouble(),
      mirostatEta: json['mirostat_eta'].toDouble(),
      penalizeNewline: json['penalize_newline'],
      stop: List<String>.from(json['stop'].map((x) => x)),
      numa: json['numa'],
      numCtx: json['num_ctx'],
      numBatch: json['num_batch'],
      numGqa: json['num_gqa'],
      numGpu: json['num_gpu'],
      mainGpu: json['main_gpu'],
      lowVram: json['low_vram'],
      f16Kv: json['f16_kv'],
      vocabOnly: json['vocab_only'],
      useMmap: json['use_mmap'],
      useMlock: json['use_mlock'],
      embeddingOnly: json['embedding_only'],
      ropeFrequencyBase: json['rope_frequency_base'].toDouble(),
      ropeFrequencyScale: json['rope_frequency_scale'].toDouble(),
      numThread: json['num_thread'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'num_keep': numKeep,
      'seed': seed,
      'num_predict': numPredict,
      'top_k': topK,
      'top_p': topP,
      'tfs_z': tfsZ,
      'typical_p': typicalP,
      'repeat_last_n': repeatLastN,
      'temperature': temperature,
      'repeat_penalty': repeatPenalty,
      'presence_penalty': presencePenalty,
      'frequency_penalty': frequencyPenalty,
      'mirostat': mirostat,
      'mirostat_tau': mirostatTau,
      'mirostat_eta': mirostatEta,
      'penalize_newline': penalizeNewline,
      'stop': stop,
      'numa': numa,
      'num_ctx': numCtx,
      'num_batch': numBatch,
      'num_gqa': numGqa,
      'num_gpu': numGpu,
      'main_gpu': mainGpu,
      'low_vram': lowVram,
      'f16_kv': f16Kv,
      'vocab_only': vocabOnly,
      'use_mmap': useMmap,
      'use_mlock': useMlock,
      'embedding_only': embeddingOnly,
      'rope_frequency_base': ropeFrequencyBase,
      'rope_frequency_scale': ropeFrequencyScale,
      'num_thread': numThread,
    }..removeWhere((_, value) => value == null);
  }
}
