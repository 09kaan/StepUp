// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_template.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChallengeTemplateCollection on Isar {
  IsarCollection<ChallengeTemplate> get challengeTemplates => this.collection();
}

const ChallengeTemplateSchema = CollectionSchema(
  name: r'ChallengeTemplate',
  id: 6038555227631800083,
  properties: {
    r'enabled': PropertySchema(
      id: 0,
      name: r'enabled',
      type: IsarType.bool,
    ),
    r'goalValue': PropertySchema(
      id: 1,
      name: r'goalValue',
      type: IsarType.double,
    ),
    r'sortOrder': PropertySchema(
      id: 2,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 3,
      name: r'title',
      type: IsarType.string,
    ),
    r'unit': PropertySchema(
      id: 4,
      name: r'unit',
      type: IsarType.byte,
      enumMap: _ChallengeTemplateunitEnumValueMap,
    ),
    r'verification': PropertySchema(
      id: 5,
      name: r'verification',
      type: IsarType.byte,
      enumMap: _ChallengeTemplateverificationEnumValueMap,
    )
  },
  estimateSize: _challengeTemplateEstimateSize,
  serialize: _challengeTemplateSerialize,
  deserialize: _challengeTemplateDeserialize,
  deserializeProp: _challengeTemplateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _challengeTemplateGetId,
  getLinks: _challengeTemplateGetLinks,
  attach: _challengeTemplateAttach,
  version: '3.1.0+1',
);

int _challengeTemplateEstimateSize(
  ChallengeTemplate object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _challengeTemplateSerialize(
  ChallengeTemplate object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.enabled);
  writer.writeDouble(offsets[1], object.goalValue);
  writer.writeLong(offsets[2], object.sortOrder);
  writer.writeString(offsets[3], object.title);
  writer.writeByte(offsets[4], object.unit.index);
  writer.writeByte(offsets[5], object.verification.index);
}

ChallengeTemplate _challengeTemplateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChallengeTemplate();
  object.enabled = reader.readBool(offsets[0]);
  object.goalValue = reader.readDouble(offsets[1]);
  object.id = id;
  object.sortOrder = reader.readLong(offsets[2]);
  object.title = reader.readString(offsets[3]);
  object.unit =
      _ChallengeTemplateunitValueEnumMap[reader.readByteOrNull(offsets[4])] ??
          ChallengeUnit.reps;
  object.verification = _ChallengeTemplateverificationValueEnumMap[
          reader.readByteOrNull(offsets[5])] ??
      VerificationKind.auto;
  return object;
}

P _challengeTemplateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (_ChallengeTemplateunitValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ChallengeUnit.reps) as P;
    case 5:
      return (_ChallengeTemplateverificationValueEnumMap[
              reader.readByteOrNull(offset)] ??
          VerificationKind.auto) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ChallengeTemplateunitEnumValueMap = {
  'reps': 0,
  'steps': 1,
  'km': 2,
  'minutes': 3,
};
const _ChallengeTemplateunitValueEnumMap = {
  0: ChallengeUnit.reps,
  1: ChallengeUnit.steps,
  2: ChallengeUnit.km,
  3: ChallengeUnit.minutes,
};
const _ChallengeTemplateverificationEnumValueMap = {
  'auto': 0,
  'manual': 1,
};
const _ChallengeTemplateverificationValueEnumMap = {
  0: VerificationKind.auto,
  1: VerificationKind.manual,
};

Id _challengeTemplateGetId(ChallengeTemplate object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _challengeTemplateGetLinks(
    ChallengeTemplate object) {
  return [];
}

void _challengeTemplateAttach(
    IsarCollection<dynamic> col, Id id, ChallengeTemplate object) {
  object.id = id;
}

extension ChallengeTemplateQueryWhereSort
    on QueryBuilder<ChallengeTemplate, ChallengeTemplate, QWhere> {
  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ChallengeTemplateQueryWhere
    on QueryBuilder<ChallengeTemplate, ChallengeTemplate, QWhereClause> {
  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterWhereClause>
      idBetween(
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
}

extension ChallengeTemplateQueryFilter
    on QueryBuilder<ChallengeTemplate, ChallengeTemplate, QFilterCondition> {
  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabled',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      goalValueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      goalValueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'goalValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      goalValueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'goalValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      goalValueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'goalValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
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

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      titleEqualTo(
    String value, {
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

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
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

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      titleLessThan(
    String value, {
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

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
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

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      titleStartsWith(
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

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      titleEndsWith(
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

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      unitEqualTo(ChallengeUnit value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      unitGreaterThan(
    ChallengeUnit value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unit',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      unitLessThan(
    ChallengeUnit value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unit',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      unitBetween(
    ChallengeUnit lower,
    ChallengeUnit upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      verificationEqualTo(VerificationKind value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verification',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      verificationGreaterThan(
    VerificationKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'verification',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      verificationLessThan(
    VerificationKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'verification',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterFilterCondition>
      verificationBetween(
    VerificationKind lower,
    VerificationKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'verification',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ChallengeTemplateQueryObject
    on QueryBuilder<ChallengeTemplate, ChallengeTemplate, QFilterCondition> {}

extension ChallengeTemplateQueryLinks
    on QueryBuilder<ChallengeTemplate, ChallengeTemplate, QFilterCondition> {}

extension ChallengeTemplateQuerySortBy
    on QueryBuilder<ChallengeTemplate, ChallengeTemplate, QSortBy> {
  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      sortByGoalValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalValue', Sort.asc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      sortByGoalValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalValue', Sort.desc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      sortByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      sortByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      sortByVerification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verification', Sort.asc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      sortByVerificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verification', Sort.desc);
    });
  }
}

extension ChallengeTemplateQuerySortThenBy
    on QueryBuilder<ChallengeTemplate, ChallengeTemplate, QSortThenBy> {
  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      thenByGoalValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalValue', Sort.asc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      thenByGoalValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalValue', Sort.desc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      thenByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      thenByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      thenByVerification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verification', Sort.asc);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QAfterSortBy>
      thenByVerificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verification', Sort.desc);
    });
  }
}

extension ChallengeTemplateQueryWhereDistinct
    on QueryBuilder<ChallengeTemplate, ChallengeTemplate, QDistinct> {
  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QDistinct>
      distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QDistinct>
      distinctByGoalValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalValue');
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QDistinct>
      distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QDistinct>
      distinctByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unit');
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeTemplate, QDistinct>
      distinctByVerification() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verification');
    });
  }
}

extension ChallengeTemplateQueryProperty
    on QueryBuilder<ChallengeTemplate, ChallengeTemplate, QQueryProperty> {
  QueryBuilder<ChallengeTemplate, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChallengeTemplate, bool, QQueryOperations> enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<ChallengeTemplate, double, QQueryOperations>
      goalValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalValue');
    });
  }

  QueryBuilder<ChallengeTemplate, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<ChallengeTemplate, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<ChallengeTemplate, ChallengeUnit, QQueryOperations>
      unitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unit');
    });
  }

  QueryBuilder<ChallengeTemplate, VerificationKind, QQueryOperations>
      verificationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verification');
    });
  }
}
