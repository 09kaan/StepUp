// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walk_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWalkSessionCollection on Isar {
  IsarCollection<WalkSession> get walkSessions => this.collection();
}

const WalkSessionSchema = CollectionSchema(
  name: r'WalkSession',
  id: 5598709616993771460,
  properties: {
    r'avgGradePercent': PropertySchema(
      id: 0,
      name: r'avgGradePercent',
      type: IsarType.double,
    ),
    r'climbingDistanceMeters': PropertySchema(
      id: 1,
      name: r'climbingDistanceMeters',
      type: IsarType.double,
    ),
    r'distanceMeters': PropertySchema(
      id: 2,
      name: r'distanceMeters',
      type: IsarType.double,
    ),
    r'elevationGainMeters': PropertySchema(
      id: 3,
      name: r'elevationGainMeters',
      type: IsarType.double,
    ),
    r'endTime': PropertySchema(
      id: 4,
      name: r'endTime',
      type: IsarType.dateTime,
    ),
    r'isActive': PropertySchema(
      id: 5,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isPaused': PropertySchema(
      id: 6,
      name: r'isPaused',
      type: IsarType.bool,
    ),
    r'lastCheckpointAt': PropertySchema(
      id: 7,
      name: r'lastCheckpointAt',
      type: IsarType.dateTime,
    ),
    r'maxAltitude': PropertySchema(
      id: 8,
      name: r'maxAltitude',
      type: IsarType.double,
    ),
    r'movingDurationSeconds': PropertySchema(
      id: 9,
      name: r'movingDurationSeconds',
      type: IsarType.long,
    ),
    r'points': PropertySchema(
      id: 10,
      name: r'points',
      type: IsarType.objectList,
      target: r'RoutePoint',
    ),
    r'startTime': PropertySchema(
      id: 11,
      name: r'startTime',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(
      id: 12,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _walkSessionEstimateSize,
  serialize: _walkSessionSerialize,
  deserialize: _walkSessionDeserialize,
  deserializeProp: _walkSessionDeserializeProp,
  idName: r'id',
  indexes: {
    r'startTime': IndexSchema(
      id: -3870335341264752872,
      name: r'startTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startTime',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isActive': IndexSchema(
      id: 8092228061260947457,
      name: r'isActive',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isActive',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'RoutePoint': RoutePointSchema},
  getId: _walkSessionGetId,
  getLinks: _walkSessionGetLinks,
  attach: _walkSessionAttach,
  version: '3.1.0+1',
);

int _walkSessionEstimateSize(
  WalkSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.points.length * 3;
  {
    final offsets = allOffsets[RoutePoint]!;
    for (var i = 0; i < object.points.length; i++) {
      final value = object.points[i];
      bytesCount += RoutePointSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _walkSessionSerialize(
  WalkSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.avgGradePercent);
  writer.writeDouble(offsets[1], object.climbingDistanceMeters);
  writer.writeDouble(offsets[2], object.distanceMeters);
  writer.writeDouble(offsets[3], object.elevationGainMeters);
  writer.writeDateTime(offsets[4], object.endTime);
  writer.writeBool(offsets[5], object.isActive);
  writer.writeBool(offsets[6], object.isPaused);
  writer.writeDateTime(offsets[7], object.lastCheckpointAt);
  writer.writeDouble(offsets[8], object.maxAltitude);
  writer.writeLong(offsets[9], object.movingDurationSeconds);
  writer.writeObjectList<RoutePoint>(
    offsets[10],
    allOffsets,
    RoutePointSchema.serialize,
    object.points,
  );
  writer.writeDateTime(offsets[11], object.startTime);
  writer.writeString(offsets[12], object.title);
}

WalkSession _walkSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WalkSession();
  object.avgGradePercent = reader.readDouble(offsets[0]);
  object.climbingDistanceMeters = reader.readDouble(offsets[1]);
  object.distanceMeters = reader.readDouble(offsets[2]);
  object.elevationGainMeters = reader.readDouble(offsets[3]);
  object.endTime = reader.readDateTimeOrNull(offsets[4]);
  object.id = id;
  object.isActive = reader.readBool(offsets[5]);
  object.isPaused = reader.readBool(offsets[6]);
  object.lastCheckpointAt = reader.readDateTimeOrNull(offsets[7]);
  object.maxAltitude = reader.readDouble(offsets[8]);
  object.movingDurationSeconds = reader.readLong(offsets[9]);
  object.points = reader.readObjectList<RoutePoint>(
        offsets[10],
        RoutePointSchema.deserialize,
        allOffsets,
        RoutePoint(),
      ) ??
      [];
  object.startTime = reader.readDateTime(offsets[11]);
  object.title = reader.readStringOrNull(offsets[12]);
  return object;
}

P _walkSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readObjectList<RoutePoint>(
            offset,
            RoutePointSchema.deserialize,
            allOffsets,
            RoutePoint(),
          ) ??
          []) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _walkSessionGetId(WalkSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _walkSessionGetLinks(WalkSession object) {
  return [];
}

void _walkSessionAttach(
    IsarCollection<dynamic> col, Id id, WalkSession object) {
  object.id = id;
}

extension WalkSessionQueryWhereSort
    on QueryBuilder<WalkSession, WalkSession, QWhere> {
  QueryBuilder<WalkSession, WalkSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterWhere> anyStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startTime'),
      );
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterWhere> anyIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isActive'),
      );
    });
  }
}

extension WalkSessionQueryWhere
    on QueryBuilder<WalkSession, WalkSession, QWhereClause> {
  QueryBuilder<WalkSession, WalkSession, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<WalkSession, WalkSession, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterWhereClause> idBetween(
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

  QueryBuilder<WalkSession, WalkSession, QAfterWhereClause> startTimeEqualTo(
      DateTime startTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startTime',
        value: [startTime],
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterWhereClause> startTimeNotEqualTo(
      DateTime startTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [],
              upper: [startTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [startTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [startTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [],
              upper: [startTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterWhereClause>
      startTimeGreaterThan(
    DateTime startTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startTime',
        lower: [startTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterWhereClause> startTimeLessThan(
    DateTime startTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startTime',
        lower: [],
        upper: [startTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterWhereClause> startTimeBetween(
    DateTime lowerStartTime,
    DateTime upperStartTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startTime',
        lower: [lowerStartTime],
        includeLower: includeLower,
        upper: [upperStartTime],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterWhereClause> isActiveEqualTo(
      bool isActive) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isActive',
        value: [isActive],
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterWhereClause> isActiveNotEqualTo(
      bool isActive) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [],
              upper: [isActive],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [isActive],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [isActive],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [],
              upper: [isActive],
              includeUpper: false,
            ));
      }
    });
  }
}

extension WalkSessionQueryFilter
    on QueryBuilder<WalkSession, WalkSession, QFilterCondition> {
  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      avgGradePercentEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgGradePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      avgGradePercentGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgGradePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      avgGradePercentLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgGradePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      avgGradePercentBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgGradePercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      climbingDistanceMetersEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'climbingDistanceMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      climbingDistanceMetersGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'climbingDistanceMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      climbingDistanceMetersLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'climbingDistanceMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      climbingDistanceMetersBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'climbingDistanceMeters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
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

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
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

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
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

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
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

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      elevationGainMetersEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'elevationGainMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      elevationGainMetersGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'elevationGainMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      elevationGainMetersLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'elevationGainMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      elevationGainMetersBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'elevationGainMeters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      endTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      endTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> endTimeEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      endTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> endTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> endTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> idBetween(
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

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> isPausedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPaused',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      lastCheckpointAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCheckpointAt',
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      lastCheckpointAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCheckpointAt',
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      lastCheckpointAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCheckpointAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      lastCheckpointAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCheckpointAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      lastCheckpointAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCheckpointAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      lastCheckpointAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCheckpointAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      maxAltitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxAltitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      maxAltitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxAltitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      maxAltitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxAltitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      maxAltitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxAltitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      movingDurationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movingDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      movingDurationSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'movingDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      movingDurationSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'movingDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      movingDurationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'movingDurationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      pointsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'points',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      pointsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'points',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      pointsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'points',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      pointsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'points',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      pointsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'points',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      pointsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'points',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      startTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      startTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      startTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension WalkSessionQueryObject
    on QueryBuilder<WalkSession, WalkSession, QFilterCondition> {
  QueryBuilder<WalkSession, WalkSession, QAfterFilterCondition> pointsElement(
      FilterQuery<RoutePoint> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'points');
    });
  }
}

extension WalkSessionQueryLinks
    on QueryBuilder<WalkSession, WalkSession, QFilterCondition> {}

extension WalkSessionQuerySortBy
    on QueryBuilder<WalkSession, WalkSession, QSortBy> {
  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> sortByAvgGradePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgGradePercent', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      sortByAvgGradePercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgGradePercent', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      sortByClimbingDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'climbingDistanceMeters', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      sortByClimbingDistanceMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'climbingDistanceMeters', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> sortByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      sortByDistanceMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      sortByElevationGainMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevationGainMeters', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      sortByElevationGainMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevationGainMeters', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> sortByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> sortByIsPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      sortByLastCheckpointAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckpointAt', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      sortByLastCheckpointAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckpointAt', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> sortByMaxAltitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAltitude', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> sortByMaxAltitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAltitude', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      sortByMovingDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      sortByMovingDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension WalkSessionQuerySortThenBy
    on QueryBuilder<WalkSession, WalkSession, QSortThenBy> {
  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByAvgGradePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgGradePercent', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      thenByAvgGradePercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgGradePercent', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      thenByClimbingDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'climbingDistanceMeters', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      thenByClimbingDistanceMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'climbingDistanceMeters', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      thenByDistanceMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      thenByElevationGainMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevationGainMeters', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      thenByElevationGainMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevationGainMeters', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByIsPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      thenByLastCheckpointAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckpointAt', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      thenByLastCheckpointAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckpointAt', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByMaxAltitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAltitude', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByMaxAltitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAltitude', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      thenByMovingDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy>
      thenByMovingDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<WalkSession, WalkSession, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension WalkSessionQueryWhereDistinct
    on QueryBuilder<WalkSession, WalkSession, QDistinct> {
  QueryBuilder<WalkSession, WalkSession, QDistinct>
      distinctByAvgGradePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgGradePercent');
    });
  }

  QueryBuilder<WalkSession, WalkSession, QDistinct>
      distinctByClimbingDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'climbingDistanceMeters');
    });
  }

  QueryBuilder<WalkSession, WalkSession, QDistinct> distinctByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distanceMeters');
    });
  }

  QueryBuilder<WalkSession, WalkSession, QDistinct>
      distinctByElevationGainMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'elevationGainMeters');
    });
  }

  QueryBuilder<WalkSession, WalkSession, QDistinct> distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<WalkSession, WalkSession, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<WalkSession, WalkSession, QDistinct> distinctByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPaused');
    });
  }

  QueryBuilder<WalkSession, WalkSession, QDistinct>
      distinctByLastCheckpointAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCheckpointAt');
    });
  }

  QueryBuilder<WalkSession, WalkSession, QDistinct> distinctByMaxAltitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxAltitude');
    });
  }

  QueryBuilder<WalkSession, WalkSession, QDistinct>
      distinctByMovingDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movingDurationSeconds');
    });
  }

  QueryBuilder<WalkSession, WalkSession, QDistinct> distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }

  QueryBuilder<WalkSession, WalkSession, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension WalkSessionQueryProperty
    on QueryBuilder<WalkSession, WalkSession, QQueryProperty> {
  QueryBuilder<WalkSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WalkSession, double, QQueryOperations>
      avgGradePercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgGradePercent');
    });
  }

  QueryBuilder<WalkSession, double, QQueryOperations>
      climbingDistanceMetersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'climbingDistanceMeters');
    });
  }

  QueryBuilder<WalkSession, double, QQueryOperations> distanceMetersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distanceMeters');
    });
  }

  QueryBuilder<WalkSession, double, QQueryOperations>
      elevationGainMetersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'elevationGainMeters');
    });
  }

  QueryBuilder<WalkSession, DateTime?, QQueryOperations> endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<WalkSession, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<WalkSession, bool, QQueryOperations> isPausedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPaused');
    });
  }

  QueryBuilder<WalkSession, DateTime?, QQueryOperations>
      lastCheckpointAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCheckpointAt');
    });
  }

  QueryBuilder<WalkSession, double, QQueryOperations> maxAltitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxAltitude');
    });
  }

  QueryBuilder<WalkSession, int, QQueryOperations>
      movingDurationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movingDurationSeconds');
    });
  }

  QueryBuilder<WalkSession, List<RoutePoint>, QQueryOperations>
      pointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'points');
    });
  }

  QueryBuilder<WalkSession, DateTime, QQueryOperations> startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }

  QueryBuilder<WalkSession, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RoutePointSchema = Schema(
  name: r'RoutePoint',
  id: -8082971389810800147,
  properties: {
    r'altitude': PropertySchema(
      id: 0,
      name: r'altitude',
      type: IsarType.double,
    ),
    r'altitudeAccuracy': PropertySchema(
      id: 1,
      name: r'altitudeAccuracy',
      type: IsarType.double,
    ),
    r'lat': PropertySchema(
      id: 2,
      name: r'lat',
      type: IsarType.double,
    ),
    r'lng': PropertySchema(
      id: 3,
      name: r'lng',
      type: IsarType.double,
    ),
    r'time': PropertySchema(
      id: 4,
      name: r'time',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _routePointEstimateSize,
  serialize: _routePointSerialize,
  deserialize: _routePointDeserialize,
  deserializeProp: _routePointDeserializeProp,
);

int _routePointEstimateSize(
  RoutePoint object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _routePointSerialize(
  RoutePoint object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.altitude);
  writer.writeDouble(offsets[1], object.altitudeAccuracy);
  writer.writeDouble(offsets[2], object.lat);
  writer.writeDouble(offsets[3], object.lng);
  writer.writeDateTime(offsets[4], object.time);
}

RoutePoint _routePointDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RoutePoint();
  object.altitude = reader.readDouble(offsets[0]);
  object.altitudeAccuracy = reader.readDouble(offsets[1]);
  object.lat = reader.readDouble(offsets[2]);
  object.lng = reader.readDouble(offsets[3]);
  object.time = reader.readDateTimeOrNull(offsets[4]);
  return object;
}

P _routePointDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension RoutePointQueryFilter
    on QueryBuilder<RoutePoint, RoutePoint, QFilterCondition> {
  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> altitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'altitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition>
      altitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'altitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> altitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'altitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> altitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'altitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition>
      altitudeAccuracyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'altitudeAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition>
      altitudeAccuracyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'altitudeAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition>
      altitudeAccuracyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'altitudeAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition>
      altitudeAccuracyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'altitudeAccuracy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> latEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> latGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> latLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> latBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> lngEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> lngGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> lngLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> lngBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lng',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> timeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'time',
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> timeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'time',
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> timeEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> timeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> timeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutePoint, RoutePoint, QAfterFilterCondition> timeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'time',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RoutePointQueryObject
    on QueryBuilder<RoutePoint, RoutePoint, QFilterCondition> {}
