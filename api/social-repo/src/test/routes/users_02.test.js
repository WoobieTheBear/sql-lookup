import request from 'supertest';

import app from '../../app.mjs';
import UserRepo from "../../repositories/user-repository.mjs";

import { Context } from '../../utilities/db-utility.mjs';

let context = null;
beforeAll(async () => {
    context = await Context.setUp();
});

afterAll(() => {
    return context.cleanUp();
});

it('create a user', async () => {
    const start = await UserRepo.count();

    const { text } = await request(app.init())
    .post('/users')
    .send({username: 'Bill', bio: 'Test bio'})
    .expect(200);
    const {id, username, bio} = JSON.parse(text);

    const afterCreate = await UserRepo.count();
    expect(afterCreate - start).toEqual(1);

    const user = await UserRepo.findById(id);
    expect(user.username).toEqual('Bill');
    expect(user.bio).toEqual('Test bio');
});
