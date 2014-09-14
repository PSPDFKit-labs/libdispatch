#!/usr/bin/env python2
import click
import os
import random
import subprocess
import sys
import textwrap

TESTS = [
    'after',
    'api',
    'c99',
    'cascade',
    'context_for_key',
    'data',
    'debug',
    'io',
    'io_net',
    'overcommit',
    'pingpong',
    'plusplus',
    'proc',
    'queue_finalizer',
    'read',
    'read2',
    'readsync',
    'select',
    'sema',
    'starfish',
    'suspend_timer',
    'timer',
    'timer_bit31',
    'timer_bit63',
    'timer_set_time',
    'timer_short',
    'timer_timeout',
    'vm',
    'priority',
    'priority2',
]

SLOW = [
    'concur',
    'drift',
    'group',
]

BROKEN = [
    'apply',
    'vnode',
]

THIS_SCRIPT = os.path.abspath(__file__)

def guess_tests_folder():
    return os.path.join(os.path.dirname(THIS_SCRIPT), 'tests')

def guess_test_harness_path():
    guess = os.path.join(os.path.dirname(THIS_SCRIPT), 'bsdtestharness')
    return os.path.exists(guess) and guess or None

@click.command()
@click.option('--categories', default="default")
@click.option('--test-folder', default=guess_tests_folder, type=click.Path())
@click.option(
    '--test-harness', default=guess_test_harness_path, type=click.Path())
@click.option('--random-seed', type=int, default=None)
def cli(categories, test_folder, test_harness, random_seed):
    categories = categories.split(',')

    tests = []
    if 'default' in categories: tests.extend(TESTS)
    if 'slow' in categories: tests.extend(SLOW)
    if 'broken' in categories: tests.extend(BROKEN)

    if random_seed:
        random.seed(random_seed)
        random.shuffle(tests)

    succeeded = []
    failed = []

    for test in tests:
        command = []
        if test_harness:
            command.append(test_harness)

        command.append(os.path.join(test_folder,
                                    'dispatch_{0}'.format(test)))

        rc = subprocess.call(command)

        if rc != 0:
            failed.append(test)
            click.secho(
                "\n*** {0} failed ***".format(test), fg='red', bold=True)
        else:
            succeeded.append(test)

    wrapper = textwrap.TextWrapper(initial_indent=" " * 4)

    click.echo("==================================================")
    click.echo("                    SUMMARY")
    click.echo("==================================================")

    if succeeded:
        click.secho("Succeeded:", fg='green')
        for line in wrapper.wrap(", ".join(succeeded)):
            click.echo(line)

        click.echo("")

    if failed:
        click.secho("Failed:", fg='red')
        for line in wrapper.wrap(", ".join(failed)):
            click.echo(line)



if __name__ == '__main__':
    cli.main()

