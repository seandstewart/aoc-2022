import typing
from __future__ import annotations

import pathlib


import yesql


class BaseMetadata(yesql.QueryMetadata):
    __dialect__ = "postgresql"
    __querylib__ = pathlib.Path(__file__).parent.resolve() / "queries"


class ElvesRepository(yesql.SyncQueryRepository):

    class metadata(BaseMetadata):
        __tablename__ = "elves"

    @typing.overload
    def persist_elves(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None) -> 'list[Any]':
        """
        """

    @typing.overload
    def persist_elves(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[True]') -> 'list[Any]':
        """
        """

    @typing.overload
    def persist_elves(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[False]') -> 'typing.Any':
        """
        """

    @typing.overload
    def persist_elves(self, /, *, elves, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None) -> 'list[Any]':
        """
        """

    @typing.overload
    def persist_elves(self, /, *, elves, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[True]') -> 'list[Any]':
        """
        """

    @typing.overload
    def persist_elves(self, /, *, elves, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[False]') -> 'typing.Any':
        """
        """

    @typing.overload
    def persist_elves_cursor(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def persist_elves_cursor(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def persist_elves_cursor(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def persist_elves_cursor(self, /, *, elves, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def persist_elves_cursor(self, /, *, elves, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def persist_elves_cursor(self, /, *, elves, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """


class MealsRepository(yesql.SyncQueryRepository):

    class metadata(BaseMetadata):
        __tablename__ = "meals"

    @typing.overload
    def all(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None) -> 'list[Any]':
        """
        """

    @typing.overload
    def all(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[True]') -> 'list[Any]':
        """
        """

    @typing.overload
    def all(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[False]') -> 'typing.Any':
        """
        """

    @typing.overload
    def all(self, /, *, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None) -> 'list[Any]':
        """
        """

    @typing.overload
    def all(self, /, *, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[True]') -> 'list[Any]':
        """
        """

    @typing.overload
    def all(self, /, *, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[False]') -> 'typing.Any':
        """
        """

    @typing.overload
    def all_cursor(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def all_cursor(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def all_cursor(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def all_cursor(self, /, *, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def all_cursor(self, /, *, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def all_cursor(self, /, *, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def get_elf_with_max_calories(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT' = None, deserializer: 'yesql.types.DeserializerT | None' = None) -> 'Any':
        """
        """

    @typing.overload
    def get_elf_with_max_calories(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[True]') -> 'Any':
        """
        """

    @typing.overload
    def get_elf_with_max_calories(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[False]') -> 'typing.Any':
        """
        """

    @typing.overload
    def get_elf_with_max_calories(self, /, *, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT' = None, deserializer: 'yesql.types.DeserializerT | None' = None) -> 'Any':
        """
        """

    @typing.overload
    def get_elf_with_max_calories(self, /, *, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[True]') -> 'Any':
        """
        """

    @typing.overload
    def get_elf_with_max_calories(self, /, *, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[False]') -> 'typing.Any':
        """
        """

    @typing.overload
    def get_total_calories_for_top_three(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.Any':
        """
        """

    @typing.overload
    def get_total_calories_for_top_three(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, coerce: 'typing.Literal[True]') -> 'typing.Any':
        """
        """

    @typing.overload
    def get_total_calories_for_top_three(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, coerce: 'typing.Literal[False]') -> 'typing.Any':
        """
        """

    @typing.overload
    def get_total_calories_for_top_three(self, /, *, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.Any':
        """
        """

    @typing.overload
    def get_total_calories_for_top_three(self, /, *, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, coerce: 'typing.Literal[True]') -> 'typing.Any':
        """
        """

    @typing.overload
    def get_total_calories_for_top_three(self, /, *, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, coerce: 'typing.Literal[False]') -> 'typing.Any':
        """
        """

    @typing.overload
    def persist_meals(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None) -> 'list[Any]':
        """
        """

    @typing.overload
    def persist_meals(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[True]') -> 'list[Any]':
        """
        """

    @typing.overload
    def persist_meals(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[False]') -> 'typing.Any':
        """
        """

    @typing.overload
    def persist_meals(self, /, *, meals, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None) -> 'list[Any]':
        """
        """

    @typing.overload
    def persist_meals(self, /, *, meals, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[True]') -> 'list[Any]':
        """
        """

    @typing.overload
    def persist_meals(self, /, *, meals, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None, deserializer: 'yesql.types.DeserializerT | None' = None, coerce: 'typing.Literal[False]') -> 'typing.Any':
        """
        """

    @typing.overload
    def persist_meals_cursor(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def persist_meals_cursor(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def persist_meals_cursor(self, /, *, instance: 'Any | None' = None, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def persist_meals_cursor(self, /, *, meals, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def persist_meals_cursor(self, /, *, meals, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

    @typing.overload
    def persist_meals_cursor(self, /, *, meals, connection: 'yesql.types.ConnectionT' = None, timeout: 'float' = 10, transaction: 'bool' = True, rollback: 'bool' = False, serializer: 'yesql.types.SerializerT | None' = None) -> 'typing.ContextManager[yesql.types.CursorT]':
        """
        """

