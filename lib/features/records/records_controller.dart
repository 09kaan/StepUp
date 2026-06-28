import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart'; // isarProvider
import '../../services/records_repository.dart';

final recordsRepoProvider = Provider<RecordsRepository>(
  (ref) => RecordsRepository(ref.watch(isarProvider)),
);

final recordsProvider = FutureProvider<PersonalRecords>(
  (ref) => ref.watch(recordsRepoProvider).compute(),
);
