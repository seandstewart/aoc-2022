import orjson
from yesql import support

class TestElvesRepository:
    def test_persist_elves(self, elves_repository, session):
        # Given
        ids = [dict(id=i) for i in range(1, 11)]
        # When
        persisted = elves_repository.persist_elves(
            elves=support.dumps(ids),
            connection=session,
        )
        saved_ids = [dict(id=r.id) for r in persisted]
        # Then
        assert saved_ids == ids


class TestMealsRepository:
    def test_persist_meals(self, elves_repository, meals_repository, session):
        # Given
        meals = [dict(calories=1000, elf_id=1), dict(calories=2000, elf_id=1)]
        elves_repository.persist_elves(
            elves=support.dumps([dict(id=1)]),
            connection=session,
        )
        # When
        persisted = meals_repository.persist_meals(
            meals=support.dumps(meals),
            connection=session,
        )
        saved_meals = [
            dict(calories=r.calories, elf_id=r.elf_id)
            for r in persisted
        ]
        # Then
        assert saved_meals == meals

    def test_get_elf_with_max_calories(
        self, elves_repository, meals_repository, session
    ):
        # Given
        elf1, elf2 = elves_repository.persist_elves(
            elves=support.dumps([dict(id=1), dict(id=2)]),
            connection=session
        )
        elf1_meals = meals_repository.persist_meals(
            meals=support.dumps([dict(calories=1000, elf_id=1), dict(calories=2000, elf_id=1)]),
            connection=session
        )
        elf2_meals = meals_repository.persist_meals(
            meals=support.dumps([dict(calories=1000, elf_id=2)]),
            connection=session
        )
        expected_max_calories = (elf1.id, sum(m.calories for m in elf1_meals))
        # When
        max_calories = meals_repository.get_elf_with_max_calories(connection=session)
        # Then
        assert max_calories == expected_max_calories
