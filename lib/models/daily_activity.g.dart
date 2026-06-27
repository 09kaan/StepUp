// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_activity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyActivityCollection on Isar {
  IsarCollection<DailyActivity> get dailyActivitys => this.collection();
}

const DailyActivitySchema = CollectionSchema(
  name: r'DailyActivity',
  id: -9126954269818939179,
  properties: {
    r'activeCalories': PropertySchema(
      id: 0,
      name: r'activeCalories',
      type: IsarType.double,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'distanceMeters': PropertySchema(
      id: 2,
      name: r'distanceMeters',
      type: IsarType.double,
    ),
    r'goalReached': PropertySchema(
      id: 3,
      name: r'goalReached',
      type: IsarType.bool,
    ),
    r'goalSteps': PropertySchema(
      id: 4,
      name: r'goalSteps',
      type: IsarType.long,
    ),
    r'steps': PropertySchema(
      id: 5,
      name: r'steps',
      type: IsarType.long,
    )
  },
  estimateSize: _dailyActivityEstimateSize,
  serialize: _dailyActivitySerialize,
  deserialize: _dailyActivityDeserialize,
  deserializeProp: _dailyActivityDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dailyActivityGetId,
  getLinks: _dailyActivityGetLinks,
  attach: _dailyActivityAttach,
  version: '3.1.0+1',
);

int _dailyActivityEstimateSize(
  DailyActivity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _dailyActivitySerialize(
  DailyActivity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.activeCalories);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeDouble(offsets[2], object.distanceMeters);
  writer.writeBool(offsets[3], object.goalReached);
  writer.writeLong(offsets[4], object.goalSteps);
  writer.writeLong(offsets[5], object.steps);
}

DailyActivity _dailyActivityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyActivity();
  object.activeCalories = reader.readDouble(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.distanceMeters = reader.readDouble(offsets[2]);
  object.goalReached = reader.readBool(offsets[3]);
  object.goalSteps = reader.readLong(offsets[4]);
  object.id = id;
  object.steps = reader.readLong(offsets[5]);
  return object;
}

P _dailyActivityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyActivityGetId(DailyActivity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyActivityGetLinks(DailyActivity object) {
  return [];
}

void _dailyActivityAttach(
    IsarCollection<dynamic> col, Id id, DailyActivity object) {
  object.id = id;
}

extension DailyActivityByIndex on IsarCollection<DailyActivity> {
  Future<DailyActivity?> getByDate(DateTime date) {
    return getByIndex(r'date', [date]);
  }

  DailyActivity? getByDateSync(DateTime date) {
    return getByIndexSync(r'date', [date]);
  }

  Future<bool> deleteByDate(DateTime date) {
    return deleteByIndex(r'date', [date]);
  }

  bool deleteByDateSync(DateTime date) {
    return deleteByIndexSync(r'date', [date]);
  }

  Future<List<DailyActivity?>> getAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndex(r'date', values);
  }

  List<DailyActivity?> getAllByDateSync(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'date', values);
  }

  Future<int> deleteAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'date', values);
  }

  int deleteAllByDateSync(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'date', values);
  }

  Future<Id> putByDate(DailyActivity object) {
    return putByIndex(r'date', object);
  }

  Id putByDateSync(DailyActivity object, {bool saveLinks = true}) {
    return putByIndexSync(r'date', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDate(List<DailyActivity> objects) {
    return putAllByIndex(r'date', objects);
  }

  List<Id> putAllByDateSync(List<DailyActivity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'date', objects, saveLinks: saveLinks);
  }
}

extension DailyActivityQueryWhereSort
    on QueryBuilder<DailyActivity, DailyActivity, QWhere> {
  QueryBuilder<DailyActivity, DailyActivity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension DailyActivityQueryWhere
    on QueryBuilder<DailyActivity, DailyActivity, QWhereClause> {
  QueryBuilder<DailyActivity, DailyActivity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterWhereClause> dateNotEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyActivityQueryFilter
    on QueryBuilder<DailyActivity, DailyActivity, QFilterCondition> {
  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      activeCaloriesEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      activeCaloriesGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      activeCaloriesLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      activeCaloriesBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeCalories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      distanceMetersEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'distanceMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      distanceMetersGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'distanceMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      distanceMetersLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'distanceMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      distanceMetersBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'distanceMeters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      goalReachedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalReached',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      goalStepsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalSteps',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      goalStepsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'goalSteps',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      goalStepsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'goalSteps',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      goalStepsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'goalSteps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      stepsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'steps',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      stepsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'steps',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      stepsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'steps',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterFilterCondition>
      stepsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'steps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyActivityQueryObject
    on QueryBuilder<DailyActivity, DailyActivity, QFilterCondition> {}

extension DailyActivityQueryLinks
    on QueryBuilder<DailyActivity, DailyActivity, QFilterCondition> {}

extension DailyActivityQuerySortBy
    on QueryBuilder<DailyActivity, DailyActivity, QSortBy> {
  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy>
      sortByActiveCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeCalories', Sort.asc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy>
      sortByActiveCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeCalories', Sort.desc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy>
      sortByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.asc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy>
      sortByDistanceMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.desc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy> sortByGoalReached() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalReached', Sort.asc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy>
      sortByGoalReachedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalReached', Sort.desc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy> sortByGoalSteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalSteps', Sort.asc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy>
      sortByGoalStepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalSteps', Sort.desc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy> sortBySteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.asc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy> sortByStepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.desc);
    });
  }
}

extension DailyActivityQuerySortThenBy
    on QueryBuilder<DailyActivity, DailyActivity, QSortThenBy> {
  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy>
      thenByActiveCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeCalories', Sort.asc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy>
      thenByActiveCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeCalories', Sort.desc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy>
      thenByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.asc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy>
      thenByDistanceMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.desc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy> thenByGoalReached() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalReached', Sort.asc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy>
      thenByGoalReachedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalReached', Sort.desc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy> thenByGoalSteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalSteps', Sort.asc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy>
      thenByGoalStepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalSteps', Sort.desc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy> thenBySteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.asc);
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QAfterSortBy> thenByStepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.desc);
    });
  }
}

extension DailyActivityQueryWhereDistinct
    on QueryBuilder<DailyActivity, DailyActivity, QDistinct> {
  QueryBuilder<DailyActivity, DailyActivity, QDistinct>
      distinctByActiveCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeCalories');
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QDistinct>
      distinctByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distanceMeters');
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QDistinct>
      distinctByGoalReached() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalReached');
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QDistinct> distinctByGoalSteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalSteps');
    });
  }

  QueryBuilder<DailyActivity, DailyActivity, QDistinct> distinctBySteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'steps');
    });
  }
}

extension DailyActivityQueryProperty
    on QueryBuilder<DailyActivity, DailyActivity, QQueryProperty> {
  QueryBuilder<DailyActivity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyActivity, double, QQueryOperations>
      activeCaloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeCalories');
    });
  }

  QueryBuilder<DailyActivity, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DailyActivity, double, QQueryOperations>
      distanceMetersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distanceMeters');
    });
  }

  QueryBuilder<DailyActivity, bool, QQueryOperations> goalReachedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalReached');
    });
  }

  QueryBuilder<DailyActivity, int, QQueryOperations> goalStepsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalSteps');
    });
  }

  QueryBuilder<DailyActivity, int, QQueryOperations> stepsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'steps');
    });
  }
}
